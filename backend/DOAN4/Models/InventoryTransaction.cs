using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class InventoryTransaction
    {
        [Key] 
        public int TransactionId { get; set; }
        public int InventoryId { get; set; }
        
        public int? PackageId { get; set; }     
        public decimal QuantityChange { get; set; }
        [StringLength(100)]
        public string Note { get; set; } = string.Empty;
        public DateTime TransactionDate { get; set; }
        public string TransactionType { get; set; } = string.Empty;
        [ForeignKey("PackageId")]
        public Package? Package { get; set; }
        [ForeignKey("InventoryId")]
            public Inventory Inventory { get; set; } 

    }
}
