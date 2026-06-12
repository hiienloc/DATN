namespace DOAN4.IRepository
{
    public interface IPaymentRepo
    {
        Task<Payment?> GetPaymentByOrderIdAsync(int orderId);
        Task CreatePaymentAsync(Payment payment);
        Task UpdatePaymentStatusAsync(int orderId, string status, string paymentMethod, DateTime updatedAt);
        Task AddTransactionAsync(PaymentTransaction transaction);
        Task<PaymentTransaction?> GetTransactionByIdAsync(int transactionId);
        Task RestoreStockAsync(int orderId);
        Task SaveChangesAsync();
    }
}