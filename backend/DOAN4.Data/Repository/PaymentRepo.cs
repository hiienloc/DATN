using DOAN4.Data;
using DOAN4.IRepository;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DOAN4.Repository
{
    public class PaymentRepo : IPaymentRepo
    {
        private readonly AppDbContext _context;
        private readonly ILogger<PaymentRepo> _logger;
        private readonly IInventoryRepo _inventoryRepo;

        public PaymentRepo(
            AppDbContext context,
            ILogger<PaymentRepo> logger,
            IInventoryRepo inventoryRepo)
        {
            _context = context;
            _logger = logger;
            _inventoryRepo = inventoryRepo;
        }

        // Lấy payment kèm danh sách transactions
        public async Task<Payment?> GetPaymentByOrderIdAsync(int orderId)
        {
            return await _context.Payments
                .Include(p => p.Transactions) // load transactions theo
                .FirstOrDefaultAsync(p => p.OrderId == orderId);
        }

        // Tạo mới payment (dùng cho COD)
        public async Task CreatePaymentAsync(Payment payment)
        {
            await _context.Payments.AddAsync(payment);
            await _context.SaveChangesAsync();
        }

        // Cập nhật status + paymentMethod + updatedAt
        public async Task UpdatePaymentStatusAsync(
            int orderId, string status, string paymentMethod, DateTime updatedAt)
        {
            var payment = await _context.Payments
                .FirstOrDefaultAsync(p => p.OrderId == orderId);

            if (payment == null)
            {
                _logger.LogWarning("[PaymentRepo] Không tìm thấy payment. OrderId={Id}", orderId);
                return;
            }

            payment.PaymentStatus = status;
            payment.PaymentMethod = paymentMethod;
            payment.UpdatedAt = updatedAt;

            await _context.SaveChangesAsync();
        }

        // Thêm 1 transaction vào bảng PaymentTransactions
        public async Task AddTransactionAsync(PaymentTransaction transaction)
        {
            await _context.PaymentTransactions.AddAsync(transaction);
            await _context.SaveChangesAsync();
        }

        // Hoàn kho khi thanh toán thất bại — giữ nguyên logic cũ
        public async Task RestoreStockAsync(int orderId)
        {
            var orderItems = await _context.OrderItems
                .Where(od => od.OrderId == orderId)
                .Include(od => od.Package)
                    .ThenInclude(p => p.PackageItems)
                        .ThenInclude(pi => pi.Product)
                            .ThenInclude(pr => pr.Inventory)
                .ToListAsync();

            if (!orderItems.Any())
            {
                _logger.LogWarning("[RestoreStock] Không có sản phẩm. OrderId={Id}", orderId);
                return;
            }

            var order = await _context.Orders.FindAsync(orderId);
            if (order != null)
            {
                order.OrderStatus = "Đã hủy";
            }
            string orderCode = order?.OrderCode ?? orderId.ToString();

            foreach (var item in orderItems)
            {
                var package = item.Package;
                if (package == null) continue;

                package.MaxQuantity += item.OrderQuantity;

                if (package.PackageItems != null && package.PackageItems.Any())
                {
                    foreach (var pkgItem in package.PackageItems)
                    {
                        var inventory = pkgItem.Product?.Inventory
                            ?? await _inventoryRepo.GetByProductIdAsync(pkgItem.ProductId);

                        if (inventory == null) continue;

                        decimal refundQty = pkgItem.PackageQty * item.OrderQuantity;

                        inventory.QtyInStock += refundQty;
                        inventory.LastUpdated = DateTime.Now;

                        await _inventoryRepo.AddTransactionAsync(new InventoryTransaction
                        {
                            InventoryId = inventory.InventoryId,
                            PackageId = package.PackageId,
                            QuantityChange = refundQty,
                            TransactionType = "IMPORT",
                            Note = $"Hoàn tồn kho do thanh toán VNPay thất bại (Đơn: {orderCode})",
                            TransactionDate = DateTime.Now
                        });

                        _logger.LogInformation(
                            "[RestoreStock] Hoàn kho ProductId={Pid}, +{Qty} (Đơn: {Code})",
                            pkgItem.ProductId, refundQty, orderCode);
                    }
                }
            }

            await _context.SaveChangesAsync();
        }
    }
}