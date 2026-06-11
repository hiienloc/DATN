using DOAN4.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class StaticController : ControllerBase  // ✅ đổi Static → Statistic
    {
        private readonly IStaticService _statisticService;  // ✅ đổi tên cho đúng

        public StaticController(IStaticService statisticService)
        {
            _statisticService = statisticService;
        }

        // GET api/Statistic/dashboard
        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboard()
        {
            var data = await _statisticService.GetDashboardAsync();
            return Ok(data);
        }

       
        [HttpGet("revenue/day")]
        public async Task<IActionResult> GetRevenueByDay([FromQuery] DateTime date)
        {
            var data = await _statisticService.GetRevenueByDayAsync(date);
            return Ok(data);
        }

       
        [HttpGet("revenue/month")]
        public async Task<IActionResult> GetRevenueByMonth([FromQuery] int year, [FromQuery] int month)
        {
            var data = await _statisticService.GetRevenueByMonthAsync(year, month);
            return Ok(data);
        }

        
        [HttpGet("revenue/year")]
        public async Task<IActionResult> GetRevenueByYear([FromQuery] int year)
        {
            var data = await _statisticService.GetRevenueByYearAsync(year);
            return Ok(data);
        }

        // GET api/Statistic/top-packages?top=10
        [HttpGet("top-packages")]
        public async Task<IActionResult> GetTopSellingPackages([FromQuery] int top = 10)
        {
            var data = await _statisticService.GetTopSellingPackagesAsync(top);
            return Ok(data);
        }
        
        // GET api/Static/revenue-details
        [HttpGet("revenue-details")]
        public async Task<IActionResult> GetRevenueDetails([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate, [FromQuery] string groupBy = "day")
        {
            var data = await _statisticService.GetRevenueDetailsAsync(fromDate, toDate, groupBy);
            return Ok(data);
        }
    }
}