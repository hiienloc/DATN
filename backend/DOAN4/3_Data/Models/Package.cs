using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class Package
    {
        [Key]
        public int PackageId { get; set; }
        [Required,StringLength(50,MinimumLength =5,ErrorMessage ="Package code must be between 5 and 50 characters.")]
        public string PackageCode { get; set; } = string.Empty;
        [Required,StringLength(50,MinimumLength =3,ErrorMessage ="Package name must be between 3 and 50 characters.")]
        public string PackageName { get; set; } = string.Empty;
        [Required, StringLength(255)]
        [Column(TypeName = "varchar(255)")]
        public string ImageUrl { get; set; } = string.Empty; 
        [Required,StringLength(255,MinimumLength =10,ErrorMessage ="Description must be between 10 and 255 characters.")]
        public string Description { get; set; } = string.Empty;
        [Required,Range(0, double.MaxValue, ErrorMessage = "Price must be a positive value.") ]
        public decimal Price { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal Discount { get; set; }
        [Required]
        public int MaxQuantity { get; set; }

        [Timestamp]
        public byte[] RowVersion { get; set; }

       // public bool IsDeleted { get; set; }
        public bool IsActive { get; set; }
        public ICollection<InventoryTransaction>? InventoryTransactions { get; set; }
         public ICollection<OrderItem>? OrderItems { get; set; }
        public ICollection<PackageItem>? PackageItems { get; set; }
        public ICollection<CartItem>? CartItems { get; set; }

    }
}
