using DOAN4.Dto;
using DOAN4.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PackageController : ControllerBase
    {
        private readonly IPackageService _packageService;
        private readonly IStorageService _storageService;

        public PackageController(IPackageService packageService, IStorageService storageService)
        {
            _packageService = packageService;
            _storageService = storageService;
        }

        // GET /api/package
        [HttpGet]
        public async Task<IActionResult> GetAllPackages()
        {
            var packages = await _packageService.GetAllPackagesAsync();
            return Ok(packages);
        }

        // GET /api/package/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetPackageById(int id)
        {
            try
            {
                var package = await _packageService.GetPackageByIdAsync(id);
                return Ok(package);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // POST /api/package/upload-image
        [Authorize(Roles = "Admin")]
        [HttpPost("upload-image")]
        public async Task<IActionResult> UploadImage(IFormFile image)
        {
            if (image == null || image.Length == 0)
                return BadRequest(new { Message = "Vui lòng chọn file ảnh." });

            try
            {
                var url = await _storageService.UploadImageAsync(image);
                return Ok(new { ImageUrl = url });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // POST /api/package/add
        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public async Task<IActionResult> AddPackage([FromBody] PackageDto.CreatePackageDto packageDto)
        {
            try
            {
                await _packageService.AddPackageAsync(packageDto);
                return Ok(new { Message = "Gói hàng thêm thành công" });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { Message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // PUT /api/package/update
        [Authorize(Roles = "Admin")]
        [HttpPut("update")]
        public async Task<IActionResult> UpdatePackage([FromBody] PackageDto.UpdatePackageDto packageDto)
        {
            try
            {
                await _packageService.UpdatePackageAsync(packageDto);
                return Ok(new { Message = "Gói hàng cập nhật thành công" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // PUT /api/package/lock/5
        [Authorize(Roles = "Admin")]
        [HttpPut("lock/{id}")]
        public async Task<IActionResult> LockPackage(int id)
        {
            try
            {
                await _packageService.LockPackageAsync(id);
                return Ok(new { Message = "Gói hàng khóa thành công" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

    }
}