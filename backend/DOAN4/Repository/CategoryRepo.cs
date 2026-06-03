using DOAN4.Data;
using DOAN4.IRepository;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Repository
{
    public class CategoryRepo : ICategoryRepo  
    {
        private readonly AppDbContext _context;  

        public CategoryRepo(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Models.Category>> GetAllCategoriesAsync()
        {
            return await _context.Categories
                .ToListAsync();
        }

        public async Task<Models.Category> GetCategoryByIdAsync(int categoryId)
        {
            return await _context.Categories
                .FirstOrDefaultAsync(c => c.CategoryId == categoryId);  
        }

        public async Task AddCategoryAsync(Models.Category category)
        {
            _context.Categories.Add(category);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateCategoryAsync(Models.Category category)
        {
            _context.Categories.Update(category);
            await _context.SaveChangesAsync();
        }

        public async Task LockCategoryAsync(int categoryId)
        {
            var category = await _context.Categories
                .FirstOrDefaultAsync(c => c.CategoryId == categoryId);

            if (category == null)
                throw new KeyNotFoundException($"Category {categoryId} not found.");

            category.IsActive = false;           
            await _context.SaveChangesAsync();
        }
    }
}