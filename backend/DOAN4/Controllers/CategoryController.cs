using DOAN4.Dto;
using DOAN4.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly ICategoryService _categoryService;

        public CategoryController(ICategoryService categoryService)
        {
            _categoryService = categoryService;
        }

     
        [HttpGet]
        public async Task<IActionResult> GetAllCategories()
        {
            var categories = await _categoryService.GetAllCategoriesAsync();
            return Ok(categories);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetCategoryById(int id)
        {
            try
            {
                var category = await _categoryService.GetCategoryByIdAsync(id);
                return Ok(category);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // WRITE — Chỉ Admin mới được phép thêm/sửa/khóa danh mục
        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public async Task<IActionResult> AddCategory([FromBody] CategoryDto.CreateCategoryDto categoryDto)
        {
            try
            {
                await _categoryService.AddCategoryAsync(categoryDto);
                return Ok(new { Message = "Danh mục thêm thành công" });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("update")]
        public async Task<IActionResult> UpdateCategory([FromBody] CategoryDto.UpdateCategoryDto categoryDto)
        {
            try
            {
                await _categoryService.UpdateCategoryAsync(categoryDto);
                return Ok(new { Message = "Danh mục cập nhật thành công" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("lock/{id}")]
        public async Task<IActionResult> LockCategory(int id)
        {
            try
            {
                await _categoryService.LockCategoryAsync(id);
                return Ok(new { Message = "Danh mục khóa thành công" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }
    }
}