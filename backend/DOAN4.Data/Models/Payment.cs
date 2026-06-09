using DOAN4.Models;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Payment
{
    [Key]
    public int PaymentId { get; set; }
    public int OrderId { get; set; }
    [Required, StringLength(50)]
    [Column(TypeName = "varchar(50)")]
    public string PaymentMethod { get; set; } = string.Empty; // VNPay, COD
    public decimal Amount { get; set; }
    [Required, StringLength(50)]
    [Column(TypeName = "varchar(50)")]
    public string PaymentStatus { get; set; } = "Pending"; 
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }

    [ForeignKey("OrderId")]
    public Order Order { get; set; } 
    public ICollection<PaymentTransaction> Transactions { get; set; }
}