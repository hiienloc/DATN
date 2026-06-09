using DOAN4.Models;

namespace DOAN4.IRepository;

public interface IAuthRepo
{
    // Dùng cho Đăng nhập và kiểm tra trùng Email khi Đăng ký
    Task<User> GetByEmailAsync(string email);

    // Dùng cho Đăng ký
    Task AddUserAsync(User user);

    // Dùng cho hàm ToggleCustomerLockAsync
    Task<User> GetByIdAsync(int id);
    Task UpdateUserAsync(User user);

    // Dùng cho hàm GetRegisteredAccountAsync
    Task<List<User>> GetUsersByRoleAsync();
}