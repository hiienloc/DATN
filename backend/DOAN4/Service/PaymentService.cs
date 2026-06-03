using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using DOAN4.Models;
using Microsoft.AspNetCore.Http;

namespace DOAN4.Service
{
    public class PaymentService : IPaymentService
    {
        private readonly IPaymentRepo _repo;
        private readonly IVnpayService _vnPayService;
        private readonly ILogger<PaymentService> _logger;

        
        public PaymentService(
            IPaymentRepo repo,
            IVnpayService vnPayService,
            ILogger<PaymentService> logger)
        {
            _repo = repo;
            _vnPayService = vnPayService;
            _logger = logger;
        }

        
        public async Task<OrderDto.VnpayCallbackResult> HandleVnpayCallbackAsync(IQueryCollection query)
        {
            // Xác thực chữ ký từ VNPay, tránh giả mạo callback
            var (isValid, data) = await _vnPayService.ValidateVnPayResponse(query);
            if (!isValid)
            {
                _logger.LogWarning("[Callback] Response không hợp lệ");
                return new OrderDto.VnpayCallbackResult { IsSuccess = false };
            }

            // Parse các thông tin VNPay trả về
            string responseCode = data.GetValueOrDefault("vnp_ResponseCode", "");
            string transactionNo = data.GetValueOrDefault("vnp_TransactionNo", "");
            string bankCode = data.GetValueOrDefault("vnp_BankCode", "");
            string payDate = data.GetValueOrDefault("vnp_PayDate", "");
            string txnRef = data.GetValueOrDefault("vnp_TxnRef", "");

            int orderId = 0;
            if (!string.IsNullOrEmpty(txnRef))
            {
                if (txnRef.Contains('_'))
                {
                    // Hỗ trợ format cũ "orderId_ticks"
                    int.TryParse(txnRef.Split('_')[0], out orderId);
                }
                else if (long.TryParse(txnRef, out long parsedPaymentId))
                {
                    // Hỗ trợ format mới: orderId * 10,000,000,000 + timestamp
                    // Chia nguyên cho 10,000,000,000 để tách lấy orderId
                    long candidateOrderId = parsedPaymentId / 10000000000L;
                    if (candidateOrderId > 0 && candidateOrderId < 1000000)
                    {
                        orderId = (int)candidateOrderId;
                    }
                }
            }

            // ResponseCode = "00" là thành công, còn lại là thất bại
            if (responseCode == "00")
            {
                await UpdatePaymentSuccessAsync(orderId, transactionNo, responseCode, bankCode, payDate, txnRef);
                return new OrderDto.VnpayCallbackResult { IsSuccess = true, OrderId = orderId };
            }

            await UpdatePaymentFailedAsync(orderId, responseCode, bankCode);
            return new OrderDto.VnpayCallbackResult
            {
                IsSuccess = false,
                OrderId = orderId,
                ResponseCode = responseCode
            };
        }


        public async Task UpdatePaymentSuccessAsync(
            int orderId, string transactionNo,
            string responseCode, string bankCode, string payDate, string txnref)
        {
            var payment = await _repo.GetPaymentByOrderIdAsync(orderId);
            if (payment == null)
            {
                _logger.LogWarning("[PaymentSuccess] Không tìm thấy payment. OrderId={Id}", orderId);
                return;
            }

            // Detect phương thức từ bankCode VNPay trả về
            // VNPAYQR = quét mã, VNBANK = chuyển khoản, INTCARD = thẻ quốc tế
            string paymentMethod = DetectPaymentMethod(bankCode);

            // Lưu lại lịch sử giao dịch thành công vào bảng PaymentTransactions
            await _repo.AddTransactionAsync(new PaymentTransaction
            {
                PaymentId = payment.PaymentId,
                VnpayTxnRef = txnref,
                TransactionNo = transactionNo,  // mã giao dịch VNPay
                BankCode = bankCode,        // ngân hàng thực hiện
                ResponseCode = responseCode,    // "00"
                Status = "Success",
                TransactionDate = DateTime.Now,


            });

            // Cập nhật bảng Payment: status Paid, ghi lại method thực tế
            await _repo.UpdatePaymentStatusAsync(orderId, "Paid", paymentMethod, DateTime.Now);

            _logger.LogInformation(
                "[PaymentSuccess] OrderId={Id}, Method={Method}", orderId, paymentMethod);
        }

        // ── 3. THANH TOÁN VNPAY THẤT BẠI ─────────────────────────────────────────
        // Lưu transaction thất bại + hoàn trả tồn kho và đặt trạng thái đơn hàng thành "Đã hủy"
        public async Task UpdatePaymentFailedAsync(int orderId, string responseCode, string bankCode)
        {
            var payment = await _repo.GetPaymentByOrderIdAsync(orderId);
            if (payment == null)
            {
                _logger.LogWarning("[PaymentFailed] Không tìm thấy payment. OrderId={Id}", orderId);
                return;
            }

            // Lưu lại lịch sử giao dịch thất bại
            await _repo.AddTransactionAsync(new PaymentTransaction
            {
                PaymentId = payment.PaymentId,
                BankCode = bankCode,
                ResponseCode = responseCode,  // mã lỗi VNPay, ví dụ "24" = user hủy
                Status = "Failed",
                TransactionDate = DateTime.Now
            });

            // Hoàn lại tồn kho và cập nhật trạng thái đơn hàng thành "Đã hủy"
            await _repo.RestoreStockAsync(orderId);

            // Cập nhật trạng thái payment thành "Failed"
            await _repo.UpdatePaymentStatusAsync(
                orderId, "Failed", payment.PaymentMethod, DateTime.Now);

            _logger.LogWarning(
                "[PaymentFailed] OrderId={Id}, Code={Code}", orderId, responseCode);
        }

        // ── 4. TẠO PAYMENT COD ────────────────────────────────────────────────────
        // Khi user chọn COD, tạo Payment + Transaction với status Pending
        // Chờ shipper xác nhận đã thu tiền mới chuyển sang Paid
        public async Task CreateCodPaymentAsync(int orderId, decimal amount)
        {
            var payment = await _repo.GetPaymentByOrderIdAsync(orderId);
            if (payment == null)
            {
                payment = new Payment
                {
                    OrderId = orderId,
                    PaymentMethod = "COD",
                    Amount = amount,
                    PaymentStatus = "Pending",  // chưa thu tiền
                    CreatedAt = DateTime.Now
                };
                await _repo.CreatePaymentAsync(payment);
            }
            else
            {
                // Nếu đã có sẵn payment do CreateOrderAsync tạo, cập nhật trạng thái
                await _repo.UpdatePaymentStatusAsync(orderId, "Pending", "COD", DateTime.Now);
            }

            // Tạo transaction đầu tiên ghi nhận đơn COD được tạo
            await _repo.AddTransactionAsync(new PaymentTransaction
            {
                PaymentId = payment.PaymentId,
                Status = "Pending",
                TransactionDate = DateTime.Now
            });

            _logger.LogInformation("[COD] Tạo payment COD. OrderId={Id}", orderId);
        }

        // ── 5. XÁC NHẬN ĐÃ THU TIỀN COD ─────────────────────────────────────────
        // Shipper/admin gọi endpoint này sau khi giao hàng và thu tiền xong
        public async Task UpdateCodPaidAsync(int orderId)
        {
            var payment = await _repo.GetPaymentByOrderIdAsync(orderId);
            if (payment == null)
            {
                _logger.LogWarning("[COD] Không tìm thấy payment. OrderId={Id}", orderId);
                return;
            }

            // Lưu transaction xác nhận thu tiền thành công
            await _repo.AddTransactionAsync(new PaymentTransaction
            {
                PaymentId = payment.PaymentId,
                Status = "Success",
                TransactionDate = DateTime.Now,


            });

            // Cập nhật Payment status = "Paid"
            await _repo.UpdatePaymentStatusAsync(orderId, "Paid", "COD", DateTime.Now);

            _logger.LogInformation("[COD] Xác nhận thanh toán. OrderId={Id}", orderId);
        }

        // ── 6. LẤY THÔNG TIN PAYMENT ─────────────────────────────────────────────
        // Controller gọi để trả về cho client, bao gồm cả danh sách transactions
        public async Task<Payment?> GetPaymentByOrderIdAsync(int orderId)
        {
            return await _repo.GetPaymentByOrderIdAsync(orderId);
        }

        // ── HELPER ────────────────────────────────────────────────────────────────
        // Detect phương thức thanh toán từ bankCode VNPay trả về
        private static string DetectPaymentMethod(string bankCode) => bankCode switch
        {
            "VNPAYQR" => "QR Code",
            "VNBANK" => "Chuyển khoản",
            "INTCARD" => "Thẻ quốc tế",
            _ => bankCode  // trường hợp khác giữ nguyên bankCode
        };

    } 
}