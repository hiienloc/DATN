using System.ComponentModel.DataAnnotations;

namespace DOAN4.Models
{
    public class Category
    {
        [Key] public int CategoryId { get; set; }
        [Required,StringLength(50)] public string CategoryName { get; set; }
        
        public bool IsActive { get; set; }
       // public bool IsDelete {  get; set;  }
        public ICollection<Product>? Products { get; set; }
    }
}
