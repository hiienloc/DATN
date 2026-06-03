using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class CartItem
    {
        [Key] public int CartItemId { get; set; }
        public int CartId { get; set; }
        [ForeignKey("CartId")]
        public Cart Cart { get; set; }
        
        public int CartQuantity { get; set; }
        [Range(0, int.MaxValue)]
        public decimal CartPrice { get; set; }
        public int PackageId { get; set; }
        [ForeignKey("PackageId")]
        public Package Package { get; set; } 
    }
}
