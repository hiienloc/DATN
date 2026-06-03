using DOAN4.Dto;

namespace DOAN4.IService
{
    public interface IForecastService
    {
        Task<List<ForecastDto.ForecastResponseDto>> GetForecastsAsync();
        Task<List<ForecastDto.ForecastResponseDto>> GetWeeklyForecastAsync();
        Task<List<ForecastDto.ForecastResponseDto>> GetDailyForecastAsync();
        Task<List<ForecastDto.ForecastResponseDto>> GetProductForecastAsync(int productId);
        Task<ForecastDto.ForecastResponseDto> GenerateProductForecastAsync(int productId);
        Task GenerateDailyForecastAsync();
        Task<ForecastDto.ActualHistoryDto> GetActualHistoryAsync(int productId);
        Task<List<DOAN4.Models.Product>> GetQualifiedProductsAsync();
    }
    
}
