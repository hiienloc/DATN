using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using DOAN4.Models;
using Microsoft.AspNetCore.Http;

namespace DOAN4.Service
{
    /// <summary>
    /// Lớp PaymentService chịu trách nhiệm xử lý các thanh toán đơn hàng (COD và VNPAY):
    /// - Tiếp nhận callback từ cổng thanh toán VNPay (HandleVnpayCallback), giải mã mã giao dịch để lấy orderId.
    /// - Cập nhật trạng thái thanh toán thành công (Paid) và lưu lịch sử giao dịch VNPay.
    /// - Xử lý thanh toán thất bại: lưu giao dịch lỗi, hoàn lại tồn kho cho đơn hàng bị hủy.
    /// - Quản lý thanh toán khi nhận hàng (COD): khởi tạo ở trạng thái Pending, cập nhật sang Paid sau khi shipper xác nhận giao hàng và thu tiền.
    /// </summary>
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

            if (!int.TryParse(txnRef, out int transactionId))
            {
                _logger.LogWarning("[Callback] Không thể parse txnRef làm transactionId. txnRef={TxnRef}", txnRef);
                return new OrderDto.VnpayCallbackResult { IsSuccess = false };
            }

            var transaction = await _repo.GetTransactionByIdAsync(transactionId);
            if (transaction == null)
            {
                _logger.LogWarning("[Callback] Không tìm thấy transaction với ID: {TxnId}", transactionId);
                return new OrderDto.VnpayCallbackResult { IsSuccess = false };
            }

            int orderId = transaction.Payment.OrderId;
            string paymentMethod = DetectPaymentMethod(bankCode);

            // Cập nhật thông tin giao dịch
            transaction.VnpayTxnRef = txnRef;
            transaction.TransactionNo = transactionNo;
            transaction.BankCode = bankCode;
            transaction.ResponseCode = responseCode;
            transaction.TransactionDate = DateTime.Now;

            if (responseCode == "00")
            {
                transaction.Status = "Success";
                await _repo.UpdatePaymentStatusAsync(orderId, "Paid", paymentMethod, DateTime.Now);
                await _repo.SaveChangesAsync();

                _logger.LogInformation("[PaymentSuccess] OrderId={Id}, Method={Method}, TransactionId={TxnId}", orderId, paymentMethod, transactionId);
                return new OrderDto.VnpayCallbackResult { IsSuccess = true, OrderId = orderId };
            }
            else
            {
                transaction.Status = "Failed";
                await _repo.RestoreStockAsync(orderId);
                await _repo.UpdatePaymentStatusAsync(orderId, "Failed", transaction.Payment.PaymentMethod, DateTime.Now);
                await _repo.SaveChangesAsync();

                _logger.LogInformation("[PaymentFailed] OrderId={Id}, Code={Code}, TransactionId={TxnId}", orderId, responseCode, transactionId);
                return new OrderDto.VnpayCallbackResult
                {
                    IsSuccess = false,
                    OrderId = orderId,
                    ResponseCode = responseCode
                };
            }
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

        public async Task<PaymentTransaction> CreatePendingTransactionAsync(int orderId)
        {
            var payment = await _repo.GetPaymentByOrderIdAsync(orderId)
                ?? throw new KeyNotFoundException($"Không tìm thấy Payment cho đơn hàng: {orderId}");

            var transaction = new PaymentTransaction
            {
                PaymentId = payment.PaymentId,
                Status = "Pending",
                TransactionDate = DateTime.Now
            };

            await _repo.AddTransactionAsync(transaction);
            return transaction;
        }

    } 
}