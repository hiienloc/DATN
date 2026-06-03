using DOAN4.IService;
using VNPAY;
using VNPAY.Models;
using VNPAY.Models.Enums;
using VNPAY.Models.Exceptions;

namespace DOAN4.Service
{
    public class VnpayService : IVnpayService
    {
        private readonly IVnpayClient _vnpayClient;
        private readonly ILogger<VnpayService> _logger;

        public VnpayService(IVnpayClient vnpayClient, ILogger<VnpayService> logger)
        {
            _vnpayClient = vnpayClient;
            _logger = logger;
        }

       
        public string GenerateVnPayUrl(
            HttpContext context, int orderId, decimal amount, string orderInfo)
        {
            var request = new VnpayPaymentRequest
            {
                Money = (double)amount,
                Description = orderInfo,
                BankCode = BankCode.ANY,      // cho user tự chọn ngân hàng
                Language = DisplayLanguage.Vietnamese
            };

            
            long unixTimestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            long encodedPaymentId = ((long)orderId * 10000000000L) + (unixTimestamp % 10000000000L);

            // Gán PaymentId qua Reflection vì setter được định nghĩa là internal
            var prop = typeof(VnpayPaymentRequest).GetProperty("PaymentId");
            if (prop != null)
            {
                prop.SetValue(request, encodedPaymentId);
            }

            var paymentUrlInfo = _vnpayClient.CreatePaymentUrl(request);

            _logger.LogInformation(
                "[VnpayService] Tạo URL thành công. OrderId={Id}, EncodedPaymentId={EncodedId}", orderId, encodedPaymentId);

            return paymentUrlInfo.Url;
        }

        // Xác thực chữ ký HMAC từ VNPay trả về
        // Tránh giả mạo callback từ bên ngoài
        public Task<(bool isValid, Dictionary<string, string> data)> ValidateVnPayResponse(
    IQueryCollection query)
        {
            // Chuyển query sang dictionary trước
            var data = query
                .Where(kv => kv.Key.StartsWith("vnp_"))
                .ToDictionary(kv => kv.Key, kv => kv.Value.ToString());

            try
            {
                
                _vnpayClient.GetPaymentResult(query); // chỉ dùng để xác thực chữ ký

                _logger.LogInformation("[VnpayService] Callback hợp lệ");
                return Task.FromResult((true, data));
            }
            catch (VnpayException ex)
            {
                _logger.LogWarning("[VnpayService] Callback không hợp lệ: {Msg}", ex.Message);
                return Task.FromResult((false, data));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[VnpayService] Lỗi xác thực callback");
                return Task.FromResult((false, data));
            }
        }
    }
}