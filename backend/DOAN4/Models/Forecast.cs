using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class Forecast
    {
        [Key] public int ForecastId { get; set; }
        public int ProductId { get; set; }
        [Required, StringLength(50)]
        [Column(TypeName = "varchar(50)")]
        public string ForecastType { get; set; } = string.Empty;
        public decimal AvgDailySales { get; set; }
        public decimal PredictQuantity { get; set; }
        public decimal SuggestReStock {  get; set; }
        public decimal CurrentStock { get; set; }
        public DateTime ForecastDate { get; set; }
        public DateTime GeneratedAt { get; set; }
        [ForeignKey("ProductId")]
        public Product? Product { get; set; }
    }
}
