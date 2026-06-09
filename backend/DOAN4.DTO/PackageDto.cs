using System.ComponentModel.DataAnnotations;

namespace DOAN4.Dto
{
    public class PackageDto
    {
        public class CreatePackageDto
        {
            [Required(ErrorMessage = "Bắt buộc nhập mã gói.")]
            public string PackageCode { get; set; } = string.Empty;

            [Required(ErrorMessage = "Bắt buộc nhập tên gói.")]
            public string PackageName { get; set; } = string.Empty;

            public string? ImageUrl { get; set; }

            [Required(ErrorMessage = "Bắt buộc nhập mô tả.")]
            public string Description { get; set; } = string.Empty;

            [Range(0.01, double.MaxValue, ErrorMessage = "Giá phải lớn hơn 0.")]
            public decimal Price { get; set; }

            public DateTime? StartDate { get; set; }
            public DateTime? EndDate { get; set; }

            [Range(0, double.MaxValue, ErrorMessage = "Giảm giá phải từ 0 trở lên.")]
            public decimal Discount { get; set; }

            [Range(0, int.MaxValue, ErrorMessage = "Số lượng tối đa không hợp lệ.")]
            public int MaxQuantity { get; set; }

            public string PackageType { get; set; } = string.Empty;
            public bool IsActive { get; set; } = true;

            public List<PackageItemDto> Items { get; set; } = new();
        }

        public class UpdatePackageDto
        {
            [Required]
            public int PackageId { get; set; }

            [Required(ErrorMessage = "Bắt buộc nhập mã gói.")]
            public string PackageCode { get; set; } = string.Empty;

            [Required(ErrorMessage = "Bắt buộc nhập tên gói.")]
            public string PackageName { get; set; } = string.Empty;

            public string? ImageUrl { get; set; }

            [Required(ErrorMessage = "Bắt buộc nhập mô tả.")]
            public string Description { get; set; } = string.Empty;

            [Range(0.01, double.MaxValue, ErrorMessage = "Giá phải lớn hơn 0.")]
            public decimal Price { get; set; }

            public DateTime? StartDate { get; set; }
            public DateTime? EndDate { get; set; }

            [Range(0, double.MaxValue, ErrorMessage = "Giảm giá phải từ 0 trở lên.")]
            public decimal Discount { get; set; }

            [Range(0, int.MaxValue, ErrorMessage = "Số lượng tối đa không hợp lệ.")]
            public int MaxQuantity { get; set; }

            public string PackageType { get; set; } = string.Empty;
            public bool IsActive { get; set; }

            public List<PackageItemDto> Items { get; set; } = new();
        }

        public class PackageItemDto
        {
            public int ProductId { get; set; }
            public decimal Quantity { get; set; }
            public string? ProductName { get; set; }
        }

        public class PackageResponseDto
        {
            public int PackageId { get; set; }
            public string PackageCode { get; set; } = string.Empty;
            public string PackageName { get; set; } = string.Empty;
            public string? ImageUrl { get; set; }
            public string Description { get; set; } = string.Empty;
            public decimal Price { get; set; }
            public DateTime StartDate { get; set; }
            public DateTime EndDate { get; set; }
            public decimal Discount { get; set; }
            public int MaxQuantity { get; set; }

            public string PackageType { get; set; } = string.Empty;
            public bool IsActive { get; set; }
            public List<PackageItemDto> Items { get; set; } = new();
        }
    }
}