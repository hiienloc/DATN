using System.ComponentModel.DataAnnotations;

namespace DOAN4.Dto
{
    public class CartDto
    {
        public class AddToCartDto
        {
            [Range(1, int.MaxValue, ErrorMessage = "PackageId không hợp lệ.")]
            public int PackageId { get; set; }

            [Range(1, int.MaxValue, ErrorMessage = "Số lượng thêm vào phải ít nhất là 1.")]
            public int Quantity { get; set; }
        }

        public class CartItemDto
        {
            public int CartItemId { get; set; }
            public int PackageId { get; set; }

            
            public string PackageName { get; set; } = string.Empty;
            public string? ImageUrl { get; set; }

            public int Quantity { get; set; } 
            public decimal Price { get; set; }    
            public int MaxQuantity { get; set; }

            
            public decimal SubTotal => Price * Quantity;
        }
        public class UpdateQuantityDto
        {
            [Range(1, int.MaxValue, ErrorMessage = "PackageId không hợp lệ.")]
            public int PackageId { get; set; }

            [Range(1, int.MaxValue, ErrorMessage = "Số lượng cập nhật phải ít nhất là 1.")]
            public int Quantity { get; set; }
        }
        public class CartResponseDto
        {
            public int CartId { get; set; }
            public int UserId { get; set; }
            public decimal TotalAmount { get; set; }
            public DateTime UpdateDate { get; set; }
            public List<CartItemDto> Items { get; set; }
        }
    }
}
