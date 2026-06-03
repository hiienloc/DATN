using DOAN4.Dto;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore.Storage;

namespace DOAN4.IRepository
{
    public interface IOrderRepo
    {
        Task<IDbContextTransaction> BeginTransactionAsync();


        Task<List<Order>> GetAllOrdersAsync();
            Task<List<Order>> GetOrdersByUserIdAsync(int userId);
            Task<Order?> GetOrderByIdAsync(int orderId);
            Task<Order> CreateOrderAsync(Order order); // nhận Order entity
            Task<Order> UpdateStatusOrderAsync(int orderId, string status);
            Task<Package?> GetPackageAsync(int packageId);
            Task SaveChangesAsync();
           
        }
    
}
