using DOAN4.Data;
using DOAN4.IRepository;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;
using System.Runtime.CompilerServices;

namespace DOAN4.Repository
{
    public class AuthRepo : IAuthRepo
    {
        private readonly AppDbContext _context;

        public AuthRepo(AppDbContext context)
        {
            _context = context;
        }

        public async Task<User> GetByEmailAsync(string email)
        {
            return await _context.Users
                         .Include(u => u.Role) 
                         .FirstOrDefaultAsync(u => u.Email == email);

        }
        public async Task AddUserAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
        }

        public async Task<User> GetByIdAsync(int userId)
        {
            return await _context.Users.FindAsync(userId);
        }
        public async Task<List<User>> GetAllUsersAsync()
        {
            return await _context.Users.ToListAsync();
        }
        public async Task ToggleLockAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user != null)
            {
                user.IsActive = !user.IsActive;
                await _context.SaveChangesAsync();
            }
        }
        

        public async Task UpdateUserAsync(User user)
        {
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }

        public async    Task<List<User>> GetUsersByRoleAsync()
        {
            return await _context.Users.Where(u => u.RoleId == 2).ToListAsync();
        }
    }
    }
