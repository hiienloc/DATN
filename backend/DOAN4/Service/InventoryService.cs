using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using DOAN4.Models;

namespace DOAN4.Service
{
    public class InventoryService : IInventoryService
    {
        private readonly IInventoryRepo _repo;

        public InventoryService(IInventoryRepo repo)
        {
            _repo = repo;
        }

        public async Task<List<InventoryDto.InventoryTransactionDto>> GetInventoryTransactionsAsync(int id)
        {
            var inventory = await _repo.GetByIdAsync(id);

            if (inventory == null)
                throw new KeyNotFoundException($"Không tìm thấy tồn kho với ID {id}");

            return (inventory.InventoryTransactions ?? new List<InventoryTransaction>())
                .Select(t => new InventoryDto.InventoryTransactionDto
            {
                InventoryId = t.InventoryId,
                PackageId = t.PackageId,
                QuantityChange = t.QuantityChange,
                TransactionType = t.TransactionType,
                Note = t.Note,
                TransactionDate = t.TransactionDate
            }).ToList();
        }

        public async Task<List<InventoryDto.InventoryResponseDto>> GetAllAsync()
        {
            var inventories = await _repo.GetAllAsync();

            return inventories.Select(i => new InventoryDto.InventoryResponseDto
            {
                Id = i.InventoryId,
                ProductId = i.ProductId,
                ProductName = i.Product?.ProductName ?? string.Empty,
                ProductCode = i.Product?.ProductCode ?? string.Empty,
                Unit = i.Product?.Unit ?? string.Empty,
                QuantityInStock = i.QtyInStock,
                MinStockLevel = i.MinStock,
                LastUpdated = i.LastUpdated
            }).ToList();
        }

        public async Task<InventoryDto.InventoryResponseDto> GetByIdAsync(int id)
        {
            var inventory = await _repo.GetByIdAsync(id);

            if (inventory == null)
                throw new KeyNotFoundException($"Không tìm thấy tồn kho với ID {id}");

            return new InventoryDto.InventoryResponseDto
            {
                Id = inventory.InventoryId,
                ProductId = inventory.ProductId,
                ProductName = inventory.Product?.ProductName ?? string.Empty,
                ProductCode = inventory.Product?.ProductCode ?? string.Empty,
                Unit = inventory.Product?.Unit ?? string.Empty,
                QuantityInStock = inventory.QtyInStock,
                MinStockLevel = inventory.MinStock,
                LastUpdated = inventory.LastUpdated
            };
        }

        public async Task<InventoryDto.InventoryResponseDto> ImportInventoryAsync(InventoryDto.ImportInventoryDto dto)
        {
           

            var inventory = await _repo.ImportInventoryAsync(
                dto.ProductId,
                dto.Quantity,
                dto.MinStockLevel,
                dto.Note
               );

            return new InventoryDto.InventoryResponseDto
            {
                Id = inventory.InventoryId,
                ProductId = inventory.ProductId,
                ProductName = inventory.Product?.ProductName ?? string.Empty,
                ProductCode = inventory.Product?.ProductCode ?? string.Empty,
                Unit = inventory.Product?.Unit ?? string.Empty,
                QuantityInStock = inventory.QtyInStock,
                MinStockLevel = inventory.MinStock,
                LastUpdated = inventory.LastUpdated
            };
        }

        public async Task<InventoryDto.InventoryResponseDto> UpdateInventoryAsync(int id, InventoryDto.UpdateInventoryDto dto)
        {
            var inventory = await _repo.UpdateInventoryAsync(id, dto.QuantityChange, dto.MinStockLevel, dto.Note);

            return new InventoryDto.InventoryResponseDto
            {
                Id = inventory.InventoryId,
                ProductId = inventory.ProductId,
                ProductName = inventory.Product?.ProductName ?? string.Empty,
                ProductCode = inventory.Product?.ProductCode ?? string.Empty,
                Unit = inventory.Product?.Unit ?? string.Empty,
                QuantityInStock = inventory.QtyInStock,
                MinStockLevel = inventory.MinStock,
                LastUpdated = inventory.LastUpdated
            };
        }
    }
}