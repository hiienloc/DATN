using System.ComponentModel.DataAnnotations;

namespace DOAN4.Dto
{
    public class OrderDto
    {
        public class CreateOrderDto
        {
            [Required(ErrorMessage = "User ID là bắt buộc.")]
            public int UserId { get; set; }

            public decimal TotalAmount { get; set; }

            [Required(ErrorMessage = "Họ tên người nhận không được để trống.")]
            [StringLength(50, MinimumLength = 3, ErrorMessage = "Họ tên người nhận phải từ 3 đến 50 ký tự.")]
            public string ReceiveName { get; set; } = string.Empty;

            [Required(ErrorMessage = "Số điện thoại nhận hàng không được để trống.")]
            [RegularExpression(@"^0\d{9}$", ErrorMessage = "Số điện thoại nhận hàng phải đúng 10 chữ số và bắt đầu bằng số 0.")]
            public string ReceivePhone { get; set; } = string.Empty;

            [Required(ErrorMessage = "Địa chỉ nhận hàng không được để trống.")]
            [StringLength(255, MinimumLength = 10, ErrorMessage = "Địa chỉ nhận hàng phải từ 10 đến 255 ký tự.")]
            public string ReceiveAddress { get; set; } = string.Empty;

            public decimal ShipmentPrice { get; set; }
            public string OrderStatus { get; set; } = string.Empty;

            [Required(ErrorMessage = "Phương thức thanh toán là bắt buộc.")]
            public string PaymentMethod { get; set; } = string.Empty;

            [MinLength(1, ErrorMessage = "Đơn hàng phải có ít nhất 1 sản phẩm.")]
            public List<OrderItemDto> OrderItems { get; set; } = new List<OrderItemDto>();
        }

        public class OrderItemDto
        {
            public int PackageId { get; set; }
            public string PackageName { get; set; } = string.Empty;
            public string ImageUrl { get; set; } = string.Empty;
            public int Quantity { get; set; }
            public decimal UnitPrice { get; set; }
           // public byte[]? RowVersion { get; set; }
        }

        public class OrderResponseDto
        {
            public int OrderId { get; set; }
            public int UserId { get; set; }
            public string OrderCode { get; set; } = string.Empty;
            public decimal TotalAmount { get; set; }
            public decimal ShipmentPrice { get; set; }
            public string ReceiveName { get; set; } = string.Empty;
            public string ReceivePhone { get; set; } = string.Empty;
            public string ReceiveAddress { get; set; } = string.Empty;
            public string OrderStatus { get; set; } = string.Empty;
            public DateTime OrderDate { get; set; }
            public List<OrderItemDto> OrderItems { get; set; } = new List<OrderItemDto>();
            public PaymentResponseDto? Payment { get; set; }
        }

        public class UpdateOrderStatusDto
        {
            public int OrderId { get; set; }
            public string OrderStatus { get; set; } = string.Empty;
        }

        public class CancelOrderDto
        {
            public int OrderId { get; set; }
        }

        public class PaymentDto
        {
            public int OrderId { get; set; }
            public string PaymentMethod { get; set; } = string.Empty;
            public decimal Amount { get; set; }
        }

        public class PaymentResponseDto
        {
            public int PaymentId { get; set; }
            public int OrderId { get; set; }
            public string PaymentMethod { get; set; } = string.Empty;
            public decimal Amount { get; set; }
            public string PaymentStatus { get; set; } = string.Empty;
            public DateTime CreatedAt { get; set; }
            public DateTime? UpdatedAt { get; set; }
            public List<TransactionDto> Transactions { get; set; } = new List<TransactionDto>();
        }

        public class TransactionDto
        {
            public int TransactionId { get; set; }
            public string? TransactionNo { get; set; }
            public string? BankCode { get; set; }
            public string? ResponseCode { get; set; }
            public string Status { get; set; } = string.Empty;
            public DateTime TransactionDate { get; set; }
        }

        public class VnpayCallbackResult
        {
            public bool IsSuccess { get; set; }
            public int OrderId { get; set; }
            public string ResponseCode { get; set; } = string.Empty;
        }
    }
}