using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class Order
    {
        [Key] public int OrderId { get; set; }
        
        [Required, StringLength(50)]
        [Column(TypeName = "varchar(50)")]
        public string OrderCode { get; set; } = string.Empty;
        [Required,StringLength(50,MinimumLength =3,ErrorMessage ="Receive name must be between 3 and 50 characters.")]
        public string ReceiveName { get; set; } = string.Empty;
        [Required,StringLength(10,MinimumLength = 10,ErrorMessage = "Receive phone must be 10 characters.")]
        [Column(TypeName = "varchar(10)")]
        public string ReceivePhone { get; set; } = string.Empty;
        [Required,StringLength(255,MinimumLength =10,ErrorMessage ="Receive address must be between 10 and 255 characters.")]
        public string ReceiveAddress { get; set; } = string.Empty;
        public decimal ShipmentPrice { get; set; }
        public DateTime OrderDate { get; set; }
        [Required, StringLength(50)]
        public string OrderStatus { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; } 

        public ICollection<OrderItem> Items { get; set; }
        public Payment Payment { get; set; }
    }
}
