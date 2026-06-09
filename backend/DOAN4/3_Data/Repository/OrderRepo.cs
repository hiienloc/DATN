using DOAN4.IRepository;
using DOAN4.Models;
using DOAN4.Data; // Thay bằng namespace chứa DbContext của bạn
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

public class OrderRepo : IOrderRepo
{
    private readonly AppDbContext _context; // Thay bằng tên DbContext thực tế của bạn

    public OrderRepo(AppDbContext context)
    {
        _context = context;
    }

    // Thực thi hàm bắt đầu giao dịch
    public async Task<IDbContextTransaction> BeginTransactionAsync()
    {
        return await _context.Database.BeginTransactionAsync();
    }

    public async Task<Order> CreateOrderAsync(Order order)
    {
        await _context.Orders.AddAsync(order);
        return order;
    }

    public async Task<List<Order>> GetAllOrdersAsync()
    {
        return await _context.Orders
            .Include(o => o.User) // ✅ Bổ sung để lấy thông tin tài khoản
            .Include(o => o.Items)
                .ThenInclude(oi => oi.Package)
            .Include(o => o.Payment)
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }

    public async Task<Order?> GetOrderByIdAsync(int orderId)
    {
        return await _context.Orders
            .Include(o => o.User)
            .Include(o => o.Items)
                .ThenInclude(oi => oi.Package)
                    .ThenInclude(p => p.PackageItems)
                        .ThenInclude(pi => pi.Product)
                            .ThenInclude(pr => pr.Inventory)
            .Include(o => o.Payment)
            .FirstOrDefaultAsync(o => o.OrderId == orderId);
    }

    public async Task<Package?> GetPackageAsync(int packageId)
    {
        return await _context.Packages
            .Include(p => p.PackageItems)
                .ThenInclude(pi => pi.Product)
                    .ThenInclude(pr => pr.Inventory)
            .FirstOrDefaultAsync(p => p.PackageId == packageId);
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }

    public async Task<Order> UpdateStatusOrderAsync(int orderId, string status)
    {
        var order = await GetOrderByIdAsync(orderId);
        if (order != null)
        {
            order.OrderStatus = status;
            await _context.SaveChangesAsync();
        }
        return order!;
    }

    public async Task<List<Order>> GetOrdersByUserIdAsync(int userId)
    {
        return await _context.Orders
            .Where(o => o.UserId == userId)
            .Include(o => o.Items)
                .ThenInclude(oi => oi.Package)
            .Include(o => o.Payment)
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }
}