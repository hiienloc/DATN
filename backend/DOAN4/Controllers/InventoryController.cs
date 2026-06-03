using DOAN4.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using static DOAN4.Dto.InventoryDto;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class InventoryController : ControllerBase
    {
        private readonly IInventoryService _inventoryService;

        public InventoryController(IInventoryService inventoryService)
        {
            _inventoryService = inventoryService;
        }

        // GET api/inventory
        // Lấy danh sách tồn kho
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _inventoryService.GetAllAsync();
            return Ok(result);
        }


        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var result = await _inventoryService.GetByIdAsync(id);
                return Ok(result);

            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // POST api/inventory/import
        // Nhập hàng vào kho → cộng thêm số lượng + ghi InventoryTransaction (IMPORT)
        [HttpPost("import")]
        public async Task<IActionResult> ImportInventory([FromBody] ImportInventoryDto dto)
        {
            try

            {
                if (dto.Quantity <= 0)
                    throw new ArgumentException("Số lượng nhập phải lớn hơn 0");

                var result = await _inventoryService.ImportInventoryAsync(dto);
                return Ok(result);
                
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // PUT api/inventory/{id}
        // Cập nhật tồn kho → ghi đè số lượng + ghi InventoryTransaction (ADJUST)
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateInventory(int id, [FromBody] UpdateInventoryDto dto)
        {
            try
            {
                var result = await _inventoryService.UpdateInventoryAsync(id, dto);
                return Ok(result);

            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // GET api/inventory/{id}/transactions
        // Lấy lịch sử giao dịch của 1 tồn kho
        [HttpGet("{id}/transactions")]
        public async Task<IActionResult> GetTransactions(int id)
        {
            try
            {
                var result = await _inventoryService.GetInventoryTransactionsAsync(id);
                return Ok(result);

            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }
    }
}
