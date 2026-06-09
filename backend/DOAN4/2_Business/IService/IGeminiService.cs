public interface IGeminiService
{
    Task<decimal> ForecastQuantityAsync(string productName, List<decimal> history, string unit = "đơn vị", int forecastDays = 7);
    Task<decimal> ForecastQuantityWithWarehouseAsync(string productName, List<decimal> salesHistory, List<decimal> exportHistory, string unit = "đơn vị", int forecastDays = 7);
}