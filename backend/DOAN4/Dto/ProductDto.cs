using System.ComponentModel.DataAnnotations;

namespace DOAN4.Dto
{
    public class ProductDto
    {
        public class Create
        {
            [Required(ErrorMessage = "Bắt buộc nhập mã sản phẩm.")]
            public string ProductCode { get; set; } = string.Empty;
            [Required(ErrorMessage = "Bắt buộc nhập tên sản phẩm.")]
            public string ProductName { get; set; } = string.Empty;
            [Required(ErrorMessage = "Bắt buộc nhập đơn vị.")]
            public string Unit { get; set; } = string.Empty;
            [Required(ErrorMessage = "Bắt buộc nhập trạng thái hoạt động.")]
            public bool IsActive { get; set; }
            public int CategoryId { get; set; }
        }
         public class Update
        {
            public int ProductId { get; set; }
            [Required(ErrorMessage = "Bắt buộc nhập mã sản phẩm.")]
            public string ProductCode { get; set; } = string.Empty;
            [Required(ErrorMessage = "Bắt buộc nhập tên sản phẩm.")]
            public string ProductName { get; set; } = string.Empty;
            [Required(ErrorMessage = "Bắt buộc nhập đơn vị.")]
            public string Unit { get; set; } = string.Empty;
            [Required(ErrorMessage = "Bắt buộc nhập trạng thái hoạt động.")]
            public bool IsActive { get; set; }
            [Required(ErrorMessage = "Bắt buộc chọn danh mục.")]
            public int CategoryId { get; set; }
        }
        public class ProductResponse
        {
            public int ProductId { get; set; }
            public string ProductCode { get; set; } = string.Empty;
            public string ProductName { get; set; } = string.Empty;
            public string Unit { get; set; } = string.Empty;
            public bool IsActive { get; set; }
           // public bool IsDeleted { get; set; }
            public int CategoryId { get; set; }
            public string CategoryName { get; set; } = string.Empty;
        }
    }
}
