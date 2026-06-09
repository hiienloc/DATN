using DOAN4.Dto;
using DOAN4.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using static DOAN4.Dto.AuthDto;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] AuthDto.RegisterDto registerDto)
        {
            var result = await _authService.RegisterAsync(registerDto);
            if (result.Success)
                return Ok(result);
            return BadRequest(result);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] AuthDto.LoginDto loginDto)
        {
            var result = await _authService.Authenticate(loginDto);
            if (result.Success)
                return Ok(result);
            return BadRequest(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("customers")]
        public async Task<ActionResult<List<UserInfoDto>>> GetAllCustomers()
        {
            var result = await _authService.GetRegisteredAccountAsync();
            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/toggle-lock")]
        public async Task<IActionResult> ToggleLock(int id)
        {
            var success = await _authService.ToggleAccountLockAsync(id);
            if (!success)
                return BadRequest(new { Message = "Không tìm thấy khách hàng hoặc không thể thay đổi trạng thái." });
            return Ok(new { Message = "Thay đổi trạng thái thành công." });
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var userId = GetUserIdFromToken();
                var profile = await _authService.GetProfileAsync(userId);
                return Ok(profile);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UserInfoDto dto)
        {
            try
            {
                var userId = GetUserIdFromToken();
                await _authService.UpdateProfileAsync(userId, dto);
                return Ok(new { Message = "Cập nhật thông tin cá nhân thành công." });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [Authorize]
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            try
            {
                var userId = GetUserIdFromToken();
                await _authService.ChangePasswordAsync(userId, dto);
                return Ok(new { Message = "Đổi mật khẩu thành công." });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // ── Helper ─────────────────────────────────────────────────────────────
        private int GetUserIdFromToken()
        {
            var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                throw new UnauthorizedAccessException("Không xác định được danh tính người dùng.");
            return int.Parse(userIdClaim.Value);
        }
    }
}
