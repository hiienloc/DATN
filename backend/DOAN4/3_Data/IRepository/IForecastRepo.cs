using DOAN4.Models;

namespace DOAN4.IRepository
{
    public interface IForecastRepo
    {
        
        Task<List<Product>> GetAllProductsAsync();

        
        Task<bool> IsProductQualifiedForForecastAsync(int productId);

        // History
        Task<List<decimal>> GetProductConsumptionHistoryAsync(int productId, int days);
        Task<List<decimal>> GetProductExportHistoryAsync(int productId, int days);

        
        Task SaveForecastAsync(Forecast forecast);
        Task<List<Forecast>> GetForecastsByDateAsync(DateTime date);
        Task<List<Forecast>> GetAllForecastsAsync();
        Task<List<Forecast>> GetForecastsByProductIdAsync(int productId);
        Task<List<Forecast>> GetForecastsByDateRangeAsync(DateTime start, DateTime end);
    }
}