using DOAN4.Dto;

namespace DOAN4.IService
{
    public interface IInventoryService
    {
        Task<List<InventoryDto.InventoryResponseDto>> GetAllAsync();
        Task<InventoryDto.InventoryResponseDto> GetByIdAsync(int id);
        Task<InventoryDto.InventoryResponseDto> ImportInventoryAsync(InventoryDto.ImportInventoryDto dto);
        Task<InventoryDto.InventoryResponseDto> UpdateInventoryAsync(int id, InventoryDto.UpdateInventoryDto dto);
        Task<List<InventoryDto.InventoryTransactionDto>> GetInventoryTransactionsAsync(int id);
    }
}
