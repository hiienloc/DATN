using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class Product
    {
        [Key] public int ProductId { get; set; }
        
        [Required,StringLength(50)]
        public string ProductCode { get; set; } = string.Empty;
        [Required,StringLength(100)]

        public string ProductName { get; set; } = string.Empty;
        [Required,StringLength(50)]
        public string Unit { get; set; } = string.Empty;
       // public bool IsDeleted { get; set; } 
        public bool IsActive { get; set; }
        public ICollection<Forecast>? Forecasts { get; set; }
         //public ICollection<OrderItem>? OrderItems { get; set; }
         public ICollection<PackageItem>? PackageItems { get; set; }
        
        public int CategoryId { get; set; }
        [ForeignKey("CategoryId")]
        public Category Category { get; set; } 
        public Inventory Inventory { get; set; }
    }
}
