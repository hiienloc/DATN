using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;

namespace DOAN4.Service
{
    public class CategoryService : ICategoryService  
    {
        private readonly ICategoryRepo _categoryRepo;  

        public CategoryService(ICategoryRepo categoryRepo)
        {
            _categoryRepo = categoryRepo;
        }

        public async Task<List<CategoryDto.CategoryResponseDto>> GetAllCategoriesAsync()
        {
            var categories = await _categoryRepo.GetAllCategoriesAsync();
            return categories.Select(c => new CategoryDto.CategoryResponseDto
            {
                CategoryId = c.CategoryId,
                CategoryName = c.CategoryName,
                IsActive = c.IsActive
            }).ToList();
        }

        public async Task<CategoryDto.CategoryResponseDto> GetCategoryByIdAsync(int categoryId)
        {
            var category = await _categoryRepo.GetCategoryByIdAsync(categoryId)
                ?? throw new KeyNotFoundException($"Category {categoryId} not found.");

            return new CategoryDto.CategoryResponseDto
            {
                CategoryId = category.CategoryId,
                CategoryName = category.CategoryName,
                IsActive = category.IsActive
            };
        }

        public async Task AddCategoryAsync(CategoryDto.CreateCategoryDto categoryDto)
        {
            var category = new Models.Category
            {
                CategoryName = categoryDto.CategoryName,
                IsActive = categoryDto.IsActive
            };
            await _categoryRepo.AddCategoryAsync(category);
        }

        public async Task UpdateCategoryAsync(CategoryDto.UpdateCategoryDto categoryDto)
        {
            var category = await _categoryRepo.GetCategoryByIdAsync(categoryDto.CategoryId)
                ?? throw new KeyNotFoundException($"Category {categoryDto.CategoryId} not found.");

            category.CategoryName = categoryDto.CategoryName;
            category.IsActive = categoryDto.IsActive;
            await _categoryRepo.UpdateCategoryAsync(category);
        }

        public async Task LockCategoryAsync(int categoryId)
        {
            await _categoryRepo.LockCategoryAsync(categoryId);
        }
    }
}