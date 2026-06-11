using System.ComponentModel.DataAnnotations;

namespace DOAN4.Dto
{
    public class AuthDto
    {
        public class RegisterDto
        {
            
            [Required(ErrorMessage = "Email không được để trống")]
            [EmailAddress(ErrorMessage = "Email không đúng định dạng")]
            public string Email { get; set; }

            [Required(ErrorMessage = "Mật khẩu không được để trống")]
            [StringLength(100, MinimumLength = 8, ErrorMessage = "Mật khẩu phải từ 6-100 ký tự")]
            public string Password { get; set; }

            [Required(ErrorMessage = "Họ tên không được để trống")]
            [StringLength(100, ErrorMessage = "Họ tên tối đa 100 ký tự")]
            public string FullName { get; set; }

            [Required(ErrorMessage = "Số điện thoại không được để trống")]
            [RegularExpression(@"^0\d{9,14}$", ErrorMessage = "Số điện thoại không hợp lệ")]
            public string PhoneNumber { get; set; }
        }
        public class LoginDto
        {
            [Required(ErrorMessage = "Email không được để trống")]
            [EmailAddress(ErrorMessage = "Email không đúng định dạng")]
            public string Email { get; set; }
            [Required(ErrorMessage = "Mật khẩu không được để trống")]
            public string Password { get; set; }
        }
        public class AuthResponseDto
        {
            public string AccessToken { get; set; }   // JWT
            public DateTime ExpireAt { get; set; }    // thời gian hết hạn

            public int UserId { get; set; }
            public string FullName { get; set; }
            public string Email { get; set; }
            public string PhoneNumber { get; set; }
            public bool IsActive { get; set; }
            public DateTime CreatedAt { get; set; } = DateTime.Now;
            public string Role { get; set; }
        }
        public class ServiceResult<T>
        {
            public bool Success { get; set; }
            public string Message { get; set; }
            public T Data { get; set; }
        }

        public class UserInfoDto
        {
            public int UserId { get; set; }
            public string FullName { get; set; }
            public string Email { get; set; }
            public string PhoneNumber { get; set; }
            public bool IsActive { get; set; }
            public DateTime CreatedAt { get; set; }
        }

        public class ChangePasswordDto
        {
            [Required]
            public string CurrentPassword { get; set; } = string.Empty;

            [Required]
            [MinLength(6)]
            public string NewPassword { get; set; } = string.Empty;
        }
    }
}
