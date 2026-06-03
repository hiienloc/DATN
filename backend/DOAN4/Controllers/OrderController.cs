using DOAN4.Dto;
using DOAN4.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;


namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class OrderController : ControllerBase
    {
        private readonly IOrderService _orderService;

        public OrderController(IOrderService orderService)
        {
            _orderService = orderService;
        }

        [HttpGet]
        public async Task<IActionResult> GetOrders([FromQuery] int? userId = null)
        {
            try
            {
                var loggedInUserId = GetUserIdFromToken();

                // Hỗ trợ lọc theo query param: Customer chỉ được lọc ID của chính mình
                if (userId.HasValue)
                {
                    if (User.IsInRole("Customer") && loggedInUserId != userId.Value)
                    {
                        return Forbid();
                    }
                    var filteredOrders = await _orderService.GetOrdersByUserIdAsync(userId.Value);
                    return Ok(filteredOrders);
                }

                // Quản trị viên: Trả về toàn bộ đơn hàng (Sửa lỗi NotImplemented cũ)
                if (User.IsInRole("Admin"))
                {
                    var allOrders = await _orderService.GetOrdersAsync();
                    return Ok(allOrders);
                }

                // Khách hàng thông thường: Tự động trả về lịch sử mua sắm của chính họ
                var myOrders = await _orderService.GetOrdersByUserIdAsync(loggedInUserId);
                return Ok(myOrders);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetOrdersByUserId(int userId)
        {
            try
            {
                var loggedInUserId = GetUserIdFromToken();

                // Bảo mật cấp cao: Ngăn chặn người dùng xem trộm đơn hàng của ID khác (IDOR)
                if (User.IsInRole("Customer") && loggedInUserId != userId)
                {
                    return Forbid();
                }

                var orders = await _orderService.GetOrdersByUserIdAsync(userId);
                return Ok(orders);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderById(int id)
        {
            try
            {
                var order = await _orderService.GetOrderByIdAsync(id);
                if (order == null) return NotFound();
                return Ok(order);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] string status)
        {
            try
            {
                var updatedOrder = await _orderService.UpdateOrderStatusAsync(id, status);
                if (updatedOrder == null) return NotFound();
                return Ok(updatedOrder);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Customer")]
        [HttpPut("{id}/cancel")]
        public async Task<IActionResult> CancelOrder(int id)
        {
            try
            {
                var order = await _orderService.CancelOrderAsync(id);
                if (order == null) return NotFound();
                return Ok(order);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Customer")]
        [HttpPost]
        public async Task<IActionResult> CreateOrder([FromBody] OrderDto.CreateOrderDto orderDto)
        {
            try
            {
                // Trích xuất an toàn UserId từ Token, chống giả mạo ID từ Client
                var userId = GetUserIdFromToken();
                orderDto.UserId = userId;

                var order = await _orderService.CreateOrderAsync(orderDto);
                return Ok(order);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }

        private int GetUserIdFromToken()
        {
            var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                throw new UnauthorizedAccessException("Không tìm thấy thông tin người dùng trong token.");
            return int.Parse(userIdClaim.Value);
        }
    }
}
