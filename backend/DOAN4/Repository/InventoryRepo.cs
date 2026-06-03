using DOAN4.Data;
using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Repository
{
    public class InventoryRepo : IInventoryRepo
    {
        private readonly AppDbContext _context;
        public InventoryRepo(AppDbContext context)
        {
            _context = context;
        }

        public async Task AddTransactionAsync(InventoryTransaction transaction)
        {
            await _context.InventoryTransactions.AddAsync(transaction);
            await _context.SaveChangesAsync();
        }

        public async Task<List<Inventory>> GetAllAsync()
        {
            // TỰ ĐỘNG ĐỒNG BỘ HÓA: Phát hiện bất kỳ sản phẩm nào chưa có bản ghi tồn kho và tự động tạo mới với số lượng = 0
            var productIds = await _context.Products.Select(p => p.ProductId).ToListAsync();
            var existingInvProductIds = await _context.Inventories.Select(i => i.ProductId).ToListAsync();
            
            var missingProductIds = productIds.Except(existingInvProductIds).ToList();
            if (missingProductIds.Any())
            {
                var newInventories = missingProductIds.Select(pid => new Inventory
                {
                    ProductId = pid,
                    QtyInStock = 0,
                    MinStock = 0,
                    LastUpdated = DateTime.Now
                }).ToList();
                
                await _context.Inventories.AddRangeAsync(newInventories);
                await _context.SaveChangesAsync();
            }

            return await _context.Inventories.Include(i => i.Product).ToListAsync();
        }

        public async Task<Inventory?> GetByIdAsync(int inventoryId)
        {
            return await _context.Inventories
                .Include(i => i.Product)
                .Include(i => i.InventoryTransactions)
                .FirstOrDefaultAsync(i => i.InventoryId == inventoryId);
        }

        public async Task<Inventory?> GetByProductIdAsync(int productId)
        {
            // Truy vấn bản ghi hiện tại
            var inventory = await _context.Inventories
                .Include(i => i.Product)
                .FirstOrDefaultAsync(i => i.ProductId == productId);

            // TỰ ĐỘNG KHỞI TẠO KHO: Nếu chưa có bản ghi, tự động tạo ngay lập tức với số dư = 0 để tránh gây crash đơn hàng!
            if (inventory == null)
            {
                var productExists = await _context.Products.AnyAsync(p => p.ProductId == productId);
                if (productExists)
                {
                    inventory = new Inventory
                    {
                        ProductId = productId,
                        QtyInStock = 0,
                        MinStock = 0,
                        LastUpdated = DateTime.Now
                    };
                    await _context.Inventories.AddAsync(inventory);
                    await _context.SaveChangesAsync();

                    // Tải lại bản ghi cùng với thực thể Product liên kết
                    inventory = await _context.Inventories
                        .Include(i => i.Product)
                        .FirstOrDefaultAsync(i => i.ProductId == productId);
                }
            }

            return inventory;
        }

        public async Task<List<InventoryTransaction>> GetTransactionsAsync(int inventoryId)
        {
            // Chuyển sang dùng ToListAsync
            return await _context.InventoryTransactions
                .Where(t => t.InventoryId == inventoryId)
                .OrderByDescending(t => t.TransactionDate) // Sắp xếp giao dịch mới nhất lên đầu
                .ToListAsync();
        }

        public async Task<Inventory> ImportInventoryAsync(int productId, decimal quantity, decimal minStockLevel, string note)
        {
           
            var inventory = await _context.Inventories
                .Include(i => i.Product)
                .FirstOrDefaultAsync(i => i.ProductId == productId);

            // chưa có inventory -> tạo mới
            if (inventory == null)
            {
                inventory = new Inventory
                {
                    ProductId = productId,
                    QtyInStock = 0,
                    LastUpdated = DateTime.UtcNow
                };

                await _context.Inventories.AddAsync(inventory);
                await _context.SaveChangesAsync();
            }

            // cộng tồn
            inventory.QtyInStock += quantity;
            inventory.MinStock = minStockLevel;
            inventory.LastUpdated = DateTime.UtcNow;

            // tạo transaction
            var transaction = new InventoryTransaction
            {
                InventoryId = inventory.InventoryId,
                QuantityChange = quantity,
                TransactionType = "IMPORT",
                Note = note,
                TransactionDate = DateTime.UtcNow
            };

            await _context.InventoryTransactions.AddAsync(transaction);

            await _context.SaveChangesAsync();

            return inventory;
        }
    







        public async Task<Inventory> UpdateInventoryAsync(int inventoryId, decimal quantity, decimal? minStockLevel, string note)
        {
            var update = await _context.Inventories.Include(i => i.InventoryTransactions).FirstOrDefaultAsync(i => i.InventoryId == inventoryId);
            if (update == null)
                throw new KeyNotFoundException($"Không tìm thấy tồn kho với ID {inventoryId}");
            // Cập nhật số lượng tồn kho
            update.QtyInStock += quantity;
            if (minStockLevel.HasValue)
            {
                update.MinStock = minStockLevel.Value;
            }
            update.LastUpdated = DateTime.UtcNow;
            // Thêm giao dịch mới vào lịch sử
            var transaction = new InventoryTransaction
            {
                InventoryId = inventoryId,
                QuantityChange = quantity,
                TransactionType = quantity > 0 ? "IMPORT" : "EXPORT",
                Note = note,
                TransactionDate = DateTime.Now
            };

            await _context.InventoryTransactions.AddAsync(transaction);
            await _context.SaveChangesAsync();

            return update;
        }
     }

       
}