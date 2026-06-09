using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DOAN4.Models
{
    public class PackageItem
    {
        [Key] 
        public int PackageItemId { get; set; }
        public int PackageId { get; set; }
        [ForeignKey("PackageId")]
        public Package Package { get; set; } = null!;
        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public Product Product { get; set; } = null!;
        public decimal PackageQty { get; set; }
    }
}
