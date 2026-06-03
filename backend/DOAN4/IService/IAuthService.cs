namespace DOAN4.IService;
    using DOAN4.Dto;

using static DOAN4.Dto.AuthDto;

public interface IAuthService
    {
        public Task<ServiceResult<AuthResponseDto>> Authenticate(LoginDto dto);
        public Task<ServiceResult<AuthResponseDto>> RegisterAsync(RegisterDto dto);
        public Task<List<UserInfoDto>> GetRegisteredAccountAsync();
        public Task<bool> ToggleAccountLockAsync(int userId);
        public Task<UserInfoDto> GetProfileAsync(int userId);
        public Task<bool> UpdateProfileAsync(int userId, UserInfoDto dto);
        public Task<bool> ChangePasswordAsync(int userId, ChangePasswordDto dto);
    }

