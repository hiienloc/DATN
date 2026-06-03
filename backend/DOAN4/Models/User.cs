using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class User
    {

        [Key]
        public int UserId { get; set; }
        [Required,StringLength(100)]
        public string FullName { get; set; } = string.Empty;
        [Required,EmailAddress,StringLength(100)]
        [Column(TypeName = "varchar(100)")]
        public string Email { get; set; } = string.Empty;
        [Required,StringLength(255,MinimumLength =8,ErrorMessage = "Password must be between 8 and 255 racters.")]
        [Column(TypeName = "varchar(255)")]
        public string Password { get; set; } = string.Empty;
        [Required,StringLength(10,MinimumLength = 10,ErrorMessage = "Phone number must be 10 characters.")]
        [Column(TypeName = "varchar(10)")]
        public string PhoneNumber { get; set; } = string.Empty; 
        
        public DateTime CreateAt { get; set; } = DateTime.Now;
        public bool IsActive { get; set; }
     
        public int RoleId { get; set; }

        [ForeignKey("RoleId")]
            public Role? Role { get; set; }

        public ICollection<Order>? Orders { get; set; }
        
        public Cart Carts { get; set; }
    }
}
