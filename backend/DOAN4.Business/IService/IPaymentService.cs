using DOAN4.Models;
using Microsoft.AspNetCore.Http;
using static DOAN4.Dto.OrderDto;

namespace DOAN4.IService
{
    public interface IPaymentService
    {
        Task<VnpayCallbackResult> HandleVnpayCallbackAsync(IQueryCollection query); // thêm
        Task UpdatePaymentSuccessAsync(int orderId, string transactionNo, string responseCode, string bankCode, string payDate,string txnref);
        Task UpdatePaymentFailedAsync(int orderId, string responseCode, string bankCode);
        Task CreateCodPaymentAsync(int orderId, decimal amount);
        Task UpdateCodPaidAsync(int orderId);
        Task<Payment?> GetPaymentByOrderIdAsync(int orderId);
        Task<PaymentTransaction> CreatePendingTransactionAsync(int orderId);
    }
}