using DOAN4.Dto;

namespace DOAN4.IService
{
    public interface ICategoryService
    {
        Task<List<CategoryDto.CategoryResponseDto>> GetAllCategoriesAsync();
        Task<CategoryDto.CategoryResponseDto> GetCategoryByIdAsync(int categoryId);
        Task AddCategoryAsync(CategoryDto.CreateCategoryDto categoryDto);
        Task UpdateCategoryAsync(CategoryDto.UpdateCategoryDto categoryDto);
        Task LockCategoryAsync(int categoryId);
    }
}