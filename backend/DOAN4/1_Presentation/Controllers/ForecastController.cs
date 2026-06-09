using DOAN4.Dto;
using DOAN4.IService;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace DOAN4.Controllers
{
    [Route("api/ForecastResult")]
    [ApiController]
    public class ForecastController : ControllerBase
    {
        private readonly IForecastService _forecastService;

        public ForecastController(IForecastService forecastService)
        {
            _forecastService = forecastService;
        }

        [HttpPost("generate")]
        public async Task<IActionResult> GenerateForecast([FromQuery] int productId)
        {
            try
            {
                var result = await _forecastService.GenerateProductForecastAsync(productId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var forecast = await _forecastService.GetForecastsAsync();
            return Ok(forecast);
        }

        [HttpGet("weekly")]
        public async Task<IActionResult> GetWeeklyForecast()
        {
            var forecast = await _forecastService.GetWeeklyForecastAsync();
            return Ok(forecast);
        }
        [HttpGet("daily")]
        public async Task<IActionResult> GetDailyForecast()
        {
            var forecast = await _forecastService.GetDailyForecastAsync();
            return Ok(forecast);
        }
        [HttpPost("generate-daily")]
        public async Task<IActionResult> GenerateDailyForecast()
        {
            await _forecastService.GenerateDailyForecastAsync();
            return Ok(new { message = "Tính toán dự báo hoàn tất!" });
        }
        [HttpGet("product-forecast/{productId}")]
        public async Task<IActionResult> GetProductForecast(int productId)
        {
            var forecast = await _forecastService.GetProductForecastAsync(productId);
            return Ok(forecast);
        }
        [HttpGet("actual-history")]
        public async Task<IActionResult> GetActualHistory([FromQuery] int productId)
        {
            try
            {
                var history = await _forecastService.GetActualHistoryAsync(productId);
                return Ok(history);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
        [HttpGet("qualified-products")]
        public async Task<IActionResult> GetQualifiedProducts()
        {
            try
            {
                var products = await _forecastService.GetQualifiedProductsAsync();
                return Ok(products);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}