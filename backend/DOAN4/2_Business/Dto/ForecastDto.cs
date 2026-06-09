namespace DOAN4.Dto
{
    public class ForecastDto
    {
        public class CreateForecastDto
        {
            public int ProductId { get; set; }
            public string ForecastType { get; set; } 
            public DateTime ForecastDate { get; set; }
        }

        public class ForecastResponseDto
        {
            public int ForecastId { get; set; }
            public int ProductId { get; set; }
            public string ProductName { get; set; }  
            public string ProductCode { get; set; } 
            public string Unit { get; set; }  
            public string ForecastType { get; set; }
            public decimal AvgDailySales { get; set; }  
            public decimal PredictQuantity { get; set; }  
            public decimal SuggestReStock { get; set; }  
            public decimal CurrentStock { get; set; }  
            public DateTime ForecastDate { get; set; }  
            public DateTime GeneratedAt { get; set; }  
        }
        public class ActualHistoryDto
        {
            public List<decimal> SalesHistory { get; set; } = new List<decimal>();
            public List<decimal> ExportHistory { get; set; } = new List<decimal>();
        }
    }
}