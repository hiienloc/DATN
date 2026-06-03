using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class OrderItem
    {
        [Key] 
        public int OrderItemId { get; set; }
        
        public int OrderId { get; set; }
        public int PackageId { get; set; }
        public decimal OrderPrice { get; set; }
        public int OrderQuantity { get; set; }
        [ForeignKey("OrderId")]
        public Order Order { get; set; } 
        [ForeignKey("PackageId")]
        public Package Package { get; set; }
    }
}
