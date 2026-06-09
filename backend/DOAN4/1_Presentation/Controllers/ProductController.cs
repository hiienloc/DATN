using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using DOAN4.IService;
using DOAN4.Dto;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IProductService _productService;

        public ProductController(IProductService productService)
        {
            _productService = productService;
        }

       
        [HttpGet]
        public async Task<IActionResult> GetAllProducts()
        {
            var products = await _productService.GetAllProductsAsync();
            return Ok(products);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetProductById(int id)
        {
            try
            {
                var product = await _productService.GetProductByIdAsync(id);
                return Ok(product);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // WRITE — Chỉ Admin mới được phép thêm/sửa/khóa sản phẩm
        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public async Task<IActionResult> AddProduct([FromBody] ProductDto.Create productDto)
        {
            try
            {
                await _productService.AddProductAsync(productDto);
                return Ok(new { Message = "Sản phẩm thêm thành công" });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("update")]
        public async Task<IActionResult> UpdateProduct([FromBody] ProductDto.Update productDto)
        {
            try
            {
                await _productService.UpdateProductAsync(productDto);
                return Ok(new { Message = "Sản phẩm cập nhật thành công" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { Message = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("lock/{id}")]
        public async Task<IActionResult> LockProduct(int id)
        {
            try
            {
                await _productService.LockProductAsync(id);
                return Ok(new { Message = "Sản phẩm khóa thành công" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }
    }
}
