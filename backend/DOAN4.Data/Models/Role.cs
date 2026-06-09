using System.ComponentModel.DataAnnotations;

namespace DOAN4.Models
{
    public class Role
    {
        [Key] 
        public int RoleId { get; set; }

        [Required, StringLength(20)]
        public string RoleName { get; set; } = string.Empty;
        public ICollection<User> Users { get; set; }
    }
}
