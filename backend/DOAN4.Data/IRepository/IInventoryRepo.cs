using DOAN4.Models;

namespace DOAN4.IRepository
{
    public interface IInventoryRepo
    {
        Task<List<Inventory>> GetAllAsync();

        Task<Inventory?> GetByIdAsync(int inventoryId);

        Task<Inventory?> GetByProductIdAsync(int productId);

        Task<List<InventoryTransaction>> GetTransactionsAsync(int inventoryId);

        Task<Inventory> ImportInventoryAsync(
            int productId,
            decimal quantity,
            decimal minStockLevel,
            string note
 );

        Task<Inventory> UpdateInventoryAsync(
            int inventoryId,
            decimal quantity,
            decimal? minStockLevel,
            string note);

        Task AddTransactionAsync(InventoryTransaction transaction);
    }
}
