using DOAN4.Data;
using DOAN4.Dto;
using DOAN4.IRepository;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Repository
{
    public class StaticRepo : IStaticRepo
    {
        private readonly AppDbContext _context;
        public StaticRepo(AppDbContext context)
        {
            _context = context;
        }

        public async Task<StaticDto.DashboardDto> GetDashboardAsync()
        {
            var today = DateTime.Today;
            var tomorrow = today.AddDays(1);

            var dashboardData = new StaticDto.DashboardDto
            {
                // Chỉ tính doanh thu từ các đơn đã "Hoàn thành"
                RevenueToday = await _context.Orders
                    .Where(o => o.OrderDate >= today && o.OrderDate < tomorrow && o.OrderStatus == "Hoàn thành")
                    .SumAsync(o => o.TotalAmount - o.ShipmentPrice),
                RevenueMonth = await _context.Orders
                    .Where(o => o.OrderDate.Year == today.Year && o.OrderDate.Month == today.Month && o.OrderStatus == "Hoàn thành")
                    .SumAsync(o => o.TotalAmount - o.ShipmentPrice),
                RevenueYear = await _context.Orders
                    .Where(o => o.OrderDate.Year == today.Year && o.OrderStatus == "Hoàn thành")
                    .SumAsync(o => o.TotalAmount - o.ShipmentPrice),
                TotalPackages = await _context.Packages.CountAsync(),
                LowStockCount = await _context.Inventories.CountAsync(i => i.QtyInStock <= i.MinStock),
                PendingOrdersCount = await _context.Orders.CountAsync(o => o.OrderStatus == "Chờ xác nhận"),
                TotalCustomersCount = await _context.Users.CountAsync(u => u.Role.RoleName == "Customer"),
                TopPackages = await GetTopSellingPackagesAsync(5)
            };
            return dashboardData;
        }

        public Task<StaticDto.RevenueByDayDto> GetRevenueByDayAsync(DateTime date)
        {
            var revenueData = _context.Orders
                .Where(o => o.OrderDate.Date == date.Date && o.OrderStatus == "Hoàn thành")
                .GroupBy(o => o.OrderDate.Date)
                .Select(g => new StaticDto.RevenueByDayDto
                {
                    Date = g.Key,
                    Revenue = g.Sum(o => o.TotalAmount - o.ShipmentPrice),
                    TotalOrders = g.Count()
                })
                .FirstOrDefault();
            return Task.FromResult(revenueData ?? new StaticDto.RevenueByDayDto { Date = date.Date, Revenue = 0, TotalOrders = 0 });
        }

        public async Task<StaticDto.RevenueByMonthDto> GetRevenueByMonthAsync(int year, int month)
        {
            var revenueData = _context.Orders
                .Where(o => o.OrderDate.Year == year && o.OrderDate.Month == month && o.OrderStatus == "Hoàn thành")
                .GroupBy(o => new { o.OrderDate.Year, o.OrderDate.Month })
                .Select(g => new StaticDto.RevenueByMonthDto
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    Revenue = g.Sum(o => o.TotalAmount - o.ShipmentPrice),
                    TotalOrders = g.Count()
                })
                .FirstOrDefault();

            return await Task.FromResult(revenueData ?? new StaticDto.RevenueByMonthDto { Year = year, Month = month, Revenue = 0, TotalOrders = 0 });
        }

        public async Task<StaticDto.RevenueByYearDto> GetRevenueByYearAsync(int year)
        {
            var revenueData = await _context.Orders
                .Where(o => o.OrderDate.Year == year && o.OrderStatus == "Hoàn thành")
                .GroupBy(o => o.OrderDate.Year)
                .Select(g => new StaticDto.RevenueByYearDto
                {
                    Year = g.Key,
                    Revenue = g.Sum(o => o.TotalAmount - o.ShipmentPrice),
                    TotalOrders = g.Count()
                })
                .FirstOrDefaultAsync();

            return revenueData ?? new StaticDto.RevenueByYearDto { Year = year, Revenue = 0, TotalOrders = 0 };
        }

        public async Task<List<StaticDto.TopSellingPackageDto>> GetTopSellingPackagesAsync(int top)
        {
            return await _context.OrderItems
                .Where(oi => oi.Order.OrderStatus == "Hoàn thành")
                .GroupBy(oi => new { oi.PackageId, oi.Package.PackageCode, oi.Package.PackageName, oi.Package.Price })
                .Select(g => new StaticDto.TopSellingPackageDto
                {
                    PackageId = g.Key.PackageId,
                    PackageCode = g.Key.PackageCode,
                    PackageName = g.Key.PackageName,
                    Price = g.Key.Price,
                    TotalSold = g.Sum(oi => oi.OrderQuantity),
                    Revenue = g.Sum(oi => oi.OrderQuantity * oi.OrderPrice)
                })
                .OrderByDescending(s => s.TotalSold)
                .Take(top)
                .ToListAsync();
        }

        public async Task<StaticDto.RevenueDetailsResponse> GetRevenueDetailsAsync(DateTime? fromDate, DateTime? toDate, string groupBy)
        {
            // Chỉ lấy các đơn hàng đã Hoàn thành
            var ordersQuery = _context.Orders.Where(o => o.OrderStatus == "Hoàn thành");

            if (fromDate.HasValue)
                ordersQuery = ordersQuery.Where(o => o.OrderDate >= fromDate.Value);
            if (toDate.HasValue)
                ordersQuery = ordersQuery.Where(o => o.OrderDate <= toDate.Value);

            var orders = await ordersQuery.ToListAsync();

            decimal totalRevenue = orders.Sum(o => o.TotalAmount - o.ShipmentPrice);
            int completedOrders = orders.Count();
            decimal avgOrderValue = completedOrders > 0 ? totalRevenue / completedOrders : 0;

            var chartData = new List<StaticDto.RevenueChartItem>();
            if (string.Equals(groupBy, "month", StringComparison.OrdinalIgnoreCase))
            {
                chartData = orders
                    .GroupBy(o => new { o.OrderDate.Year, o.OrderDate.Month })
                    .OrderBy(g => g.Key.Year).ThenBy(g => g.Key.Month)
                    .Select(g => new StaticDto.RevenueChartItem
                    {
                        TimeLabel = $"{g.Key.Month:00}/{g.Key.Year}",
                        Amount = g.Sum(o => o.TotalAmount - o.ShipmentPrice)
                    }).ToList();
            }
            else
            {
                chartData = orders
                    .GroupBy(o => o.OrderDate.Date)
                    .OrderBy(g => g.Key)
                    .Select(g => new StaticDto.RevenueChartItem
                    {
                        TimeLabel = g.Key.ToString("dd/MM"),
                        Amount = g.Sum(o => o.TotalAmount - o.ShipmentPrice)
                    }).ToList();
            }

            var orderIds = orders.Select(o => o.OrderId).ToList();
            var packageSalesList = await _context.OrderItems
                .Where(oi => orderIds.Contains(oi.OrderId))
                .GroupBy(oi => new { oi.PackageId, oi.Package.PackageName })
                .Select(g => new StaticDto.PackageSalesItem
                {
                    PackageId = g.Key.PackageId,
                    PackageName = g.Key.PackageName,
                    QuantitySold = g.Sum(oi => oi.OrderQuantity),
                    TotalAmount = g.Sum(oi => oi.OrderQuantity * oi.OrderPrice)
                })
                .OrderByDescending(p => p.QuantitySold)
                .ToListAsync();

            return new StaticDto.RevenueDetailsResponse
            {
                TotalRevenue = totalRevenue,
                CompletedOrdersCount = completedOrders,
                AverageOrderValue = avgOrderValue,
                RevenueChart = chartData,
                PackageSales = packageSalesList
            };
        }
    }
}
