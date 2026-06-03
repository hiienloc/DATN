using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using DOAN4.Models;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using static DOAN4.Dto.AuthDto;

namespace DOAN4.Service
{
 
    public class AuthService : IAuthService
    {
        
        private readonly IAuthRepo _authRepo;
        private readonly IConfiguration _config;

        public AuthService(IAuthRepo authRepo, IConfiguration config)
        {
            _authRepo = authRepo;
            _config = config;
        }

        // Hàm băm mật khẩu SHA-256
        private static string HashPassword(string password)
        {
            using var sha256 = SHA256.Create();
            var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToHexString(bytes).ToLower();
        }


        public async Task<ServiceResult<AuthResponseDto>> RegisterAsync(RegisterDto dto)
        {
            var email = dto.Email.Trim().ToLower();
            var check = await _authRepo.GetByEmailAsync(email);
            if (check != null)
            {
                return new ServiceResult<AuthResponseDto>
                {
                    Success = false,
                    Message = "Email đã tồn tại"
                };
            }

            var newUser = new User
            {
                Email = email,
                Password = HashPassword(dto.Password), // Băm mật khẩu khi đăng ký
                FullName = dto.FullName,
                PhoneNumber = dto.PhoneNumber,
                RoleId = 2,
                IsActive = true, // Lưu thẳng kiểu bool
                CreateAt = DateTime.Now
            };

            await _authRepo.AddUserAsync(newUser);
            return new ServiceResult<AuthResponseDto>
            {
                Success = true,
                Message = "Đăng ký thành công"
            };
        }

        private string GenerateToken(User user, DateTime expire)
        {
            var roleName = user.Role?.RoleName ?? "Customer";

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, roleName),
                new Claim("FullName", user.FullName)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: expire,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

       
        public async Task<List<UserInfoDto>> GetRegisteredAccountAsync()
        {
           
            var customers = await _authRepo.GetUsersByRoleAsync();

            return customers.Select(u => new UserInfoDto
            {
                UserId = u.UserId,
                FullName = u.FullName,
                Email = u.Email,
                PhoneNumber = u.PhoneNumber,
                CreatedAt = u.CreateAt,
                IsActive = u.IsActive
            }).ToList();
        }


        public async Task<ServiceResult<AuthResponseDto>> Authenticate(LoginDto dto)
        {

            var email = dto.Email.Trim().ToLower();
            var user = await _authRepo.GetByEmailAsync(email);

            // So sánh mật khẩu đã băm, hỗ trợ fallback mật khẩu trơn cho tài khoản cũ
            if (user == null || (user.Password != HashPassword(dto.Password) && user.Password != dto.Password))
            {
                return new ServiceResult<AuthResponseDto>
                {
                    Success = false,
                    Message = "Email hoặc mật khẩu không chính xác"
                };
            }
            if (user.IsActive != true)
            {
                return new ServiceResult<AuthResponseDto>
                {
                    Success = false,
                    Message = "Tài khoản đã bị khóa"
                };
            }

            var expire = DateTime.Now.AddDays(1);
            var token = GenerateToken(user, expire);

            return new ServiceResult<AuthResponseDto>
            {
                Success = true,
                Message = "Đăng nhập thành công",
                Data = new AuthResponseDto
                {
                    AccessToken = token,
                    ExpireAt = expire,
                    UserId = user.UserId,
                    FullName = user.FullName,
                    Email = user.Email,
                    PhoneNumber = user.PhoneNumber,
                    Role = user.Role?.RoleName ?? "Customer"
                }
            };

        }


        public async Task<bool> ToggleAccountLockAsync(int customerId)
        {
            var user = await _authRepo.GetByIdAsync(customerId);
            
            if (user == null || user.RoleId != 2)
            {
                return false;
            }

           
            user.IsActive = !user.IsActive;
            await _authRepo.UpdateUserAsync(user);
            return true;
        }

        public async Task<UserInfoDto> GetProfileAsync(int userId)
        {
            var user = await _authRepo.GetByIdAsync(userId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy người dùng");

            return new UserInfoDto
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                CreatedAt = user.CreateAt,
                IsActive = user.IsActive
            };
        }

        public async Task<bool> UpdateProfileAsync(int userId, UserInfoDto dto)
        {
            var user = await _authRepo.GetByIdAsync(userId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy người dùng");

            user.FullName = dto.FullName;
            user.PhoneNumber = dto.PhoneNumber;
            var cleanEmail = dto.Email.Trim().ToLower();
            if (user.Email.ToLower() != cleanEmail)
            {
                var existingUser = await _authRepo.GetByEmailAsync(cleanEmail);
                if (existingUser != null && existingUser.UserId != userId)
                {
                    throw new Exception("Email đã được sử dụng bởi người dùng khác");
                }
                user.Email = cleanEmail;
            }

            await _authRepo.UpdateUserAsync(user);
            return true;
        }

        public async Task<bool> ChangePasswordAsync(int userId, ChangePasswordDto dto)
        {
            var user = await _authRepo.GetByIdAsync(userId);
            if (user == null)
                throw new KeyNotFoundException("Không tìm thấy người dùng");

            // So sánh mật khẩu hiện tại (chấp nhận cả băm và trơn)
            if (user.Password != HashPassword(dto.CurrentPassword) && user.Password != dto.CurrentPassword)
                throw new Exception("Mật khẩu hiện tại không chính xác");

            // Lưu mật khẩu mới dưới dạng băm
            user.Password = HashPassword(dto.NewPassword);
            await _authRepo.UpdateUserAsync(user);
            return true;
        }
    }
}