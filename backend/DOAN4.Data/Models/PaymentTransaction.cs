using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class PaymentTransaction
{
    [Key]
    public int TransactionId { get; set; }
    public int PaymentId { get; set; }          // FK -> Payment

    [StringLength(50)]
    [Column(TypeName = "varchar(50)")]
    public string? VnpayTxnRef { get; set; }    // mã txnRef gửi lên VNPay

    [StringLength(50)]
    [Column(TypeName = "varchar(50)")]
    public string? TransactionNo { get; set; }  

    [StringLength(20)]
    [Column(TypeName = "varchar(20)")]
    public string? BankCode { get; set; }

    [StringLength(10)]
    [Column(TypeName = "varchar(10)")]
    public string? ResponseCode { get; set; }   // 00 = thành công
    [Required, StringLength(50)]
    [Column(TypeName = "varchar(50)")]
    public string Status { get; set; } = string.Empty; // Success, Failed
    public DateTime TransactionDate { get; set; } = DateTime.Now;

    [ForeignKey("PaymentId")]
    public Payment Payment { get; set; } = null!;
}