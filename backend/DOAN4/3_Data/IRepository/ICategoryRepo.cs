using DOAN4.Models;

namespace DOAN4.IRepository
{
    public interface  ICategoryRepo
    {
         Task<List<Category>> GetAllCategoriesAsync();
         Task<Category> GetCategoryByIdAsync(int categoryId);
         Task AddCategoryAsync(Category category);
         Task UpdateCategoryAsync(Category category);
         Task LockCategoryAsync(int categoryId);

    }
}
