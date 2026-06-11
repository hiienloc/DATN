using DOAN4.Dto;
using DOAN4.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Customer")]
    public class CartController : ControllerBase
    {
        private readonly ICartService _cartService;

        public CartController(ICartService cartService)
        {
            _cartService = cartService;
        }

        // GET api/Cart/my-cart
        [HttpGet("my-cart")]
        public async Task<IActionResult> GetMyCart()
        {
            try
            {
                var userId = GetUserIdFromToken();
                var cart = await _cartService.GetCartByUserIdAsync(userId);
                if (cart == null) return Ok(new { items = new List<object>(), totalAmount = 0 });
                return Ok(cart);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        // POST api/Cart/add
        [HttpPost("add")]
        public async Task<IActionResult> AddToCart([FromBody] CartDto.AddToCartDto cartDto)
        {
            try
            {
                var userId = GetUserIdFromToken();
                await _cartService.AddToCartAsync(userId, cartDto);
                return Ok(new { Message = "Thêm vào giỏ hàng thành công" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // PUT api/Cart/update
        [HttpPut("update")]
        public async Task<IActionResult> UpdateCart([FromBody] CartDto.UpdateQuantityDto cartDto)
        {
            try
            {
                var userId = GetUserIdFromToken();
                await _cartService.UpdateCartAsync(userId, cartDto);
                return Ok(new { Message = "Cập nhật giỏ hàng thành công" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // DELETE api/Cart/remove/{cartId}
        [HttpDelete("remove/{cartId}")]
        public async Task<IActionResult> RemoveFromCart(int cartId)
        {
            try
            {
                await _cartService.RemoveFromCartAsync(cartId);
                return Ok(new { Message = "Xóa sản phẩm khỏi giỏ hàng thành công" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // DELETE api/Cart/clear
        [HttpDelete("clear")]
        public async Task<IActionResult> ClearCart()
        {
            try
            {
                var userId = GetUserIdFromToken();
                await _cartService.ClearCartAsync(userId);
                return Ok(new { Message = "Xóa toàn bộ giỏ hàng thành công" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
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
