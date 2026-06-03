using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class Cart
    {
        [Key] 
        public int CartId { get; set; }
        public decimal TotalPrice { get; set; }
         public int UserId { get; set; }
        [ForeignKey("UserId")]
         public User User { get; set; } 
         public ICollection<CartItem> CartItems { get; set; }
    }
}
