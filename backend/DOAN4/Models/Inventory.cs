using Microsoft.Identity.Client;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class Inventory
    {
        [Key]
        public int InventoryId { get; set; }
        public int ProductId { get; set; } 
        public decimal QtyInStock { get; set; }
        public decimal MinStock { get; set; }
        public DateTime LastUpdated { get; set; } 
        public ICollection<InventoryTransaction>? InventoryTransactions { get; set; }
        [ForeignKey("ProductId")]
        public Product Product { get; set; } = null!;
        [Timestamp]
        public byte[] RowVersion { get; set; }
    }
}
