using DOAN4.Data;
using DOAN4.IRepository;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Repository
{
    public class ForecastRepo : IForecastRepo
    {
        private readonly AppDbContext _context;
        public ForecastRepo(AppDbContext context) => _context = context;


        public async Task<List<Product>> GetAllProductsAsync()
        {
            // Dùng join trực tiếp vào PackageItems thay vì SelectMany navigation property
            // để EF Core dịch đúng sang SQL JOIN
            var completedProductIds = await (
                from oi in _context.OrderItems
                join pi in _context.PackageItems on oi.PackageId equals pi.PackageId
                join o in _context.Orders on oi.OrderId equals o.OrderId
                join p in _context.Payments on o.OrderId equals p.OrderId into payments
                from pay in payments.DefaultIfEmpty()
                where o.OrderStatus == "Hoàn thành"
                   || (pay != null && (pay.PaymentStatus == "Paid" || pay.PaymentStatus == "Đã thanh toán"))
                select pi.ProductId
            ).Distinct().ToListAsync();

            Console.WriteLine($"[DEBUG] completedProductIds lấy được: {string.Join(", ", completedProductIds)}");

            var result = await _context.Products
                .Where(p => completedProductIds.Contains(p.ProductId))
                .ToListAsync();

            Console.WriteLine($"[DEBUG] Số lượng sản phẩm trả về: {result.Count}");
            return result;
        }


        public async Task<bool> IsProductQualifiedForForecastAsync(int productId)
        {
            return await (
                from oi in _context.OrderItems
                join pi in _context.PackageItems on oi.PackageId equals pi.PackageId
                join o in _context.Orders on oi.OrderId equals o.OrderId
                join p in _context.Payments on o.OrderId equals p.OrderId into payments
                from pay in payments.DefaultIfEmpty()
                where (o.OrderStatus == "Hoàn thành"
                    || (pay != null && (pay.PaymentStatus == "Paid" || pay.PaymentStatus == "Đã thanh toán")))
                    && pi.ProductId == productId
                select pi.PackageItemId
            ).AnyAsync();
        }
        public async Task<List<decimal>> GetProductConsumptionHistoryAsync(int productId, int days)
        {
            var startDate = DateTime.Today.AddDays(-days);
            var today = DateTime.Today;

            var dbData = await (
                from oi in _context.OrderItems
                join pi in _context.PackageItems on oi.PackageId equals pi.PackageId
                join o in _context.Orders on oi.OrderId equals o.OrderId
                join p in _context.Payments on o.OrderId equals p.OrderId into payments
                from pay in payments.DefaultIfEmpty()
                where pi.ProductId == productId
                   && o.OrderDate >= startDate
                   && (o.OrderStatus == "Hoàn thành"
                       || (pay != null && (pay.PaymentStatus == "Paid" || pay.PaymentStatus == "Đã thanh toán")))
                group new { pi, oi } by o.OrderDate.Date into g
                select new {
                    Date = g.Key,
                    Quantity = g.Sum(x => (decimal)(x.pi.PackageQty * x.oi.OrderQuantity))
                }
            ).ToListAsync();

            var result = new List<decimal>();
            for (int i = days; i >= 1; i--)
            {
                var date = today.AddDays(-i);
                var match = dbData.FirstOrDefault(d => d.Date == date);
                result.Add(match?.Quantity ?? 0);
            }
            return result;
        }

        // Lịch sử xuất kho thực tế — chỉ tính EXPORT gắn với đơn hoàn thành
        public async Task<List<decimal>> GetProductExportHistoryAsync(int productId, int days)
        {
            var startDate = DateTime.Today.AddDays(-days);
            var today = DateTime.Today;

            // Lấy các PackageId thuộc đơn hoàn thành trong khoảng thời gian
            var completedPackageIds = await (
                from oi in _context.OrderItems
                join o in _context.Orders on oi.OrderId equals o.OrderId
                join p in _context.Payments on o.OrderId equals p.OrderId into payments
                from pay in payments.DefaultIfEmpty()
                where o.OrderDate >= startDate
                   && (o.OrderStatus == "Hoàn thành"
                       || (pay != null && (pay.PaymentStatus == "Paid" || pay.PaymentStatus == "Đã thanh toán")))
                select oi.PackageId
            ).Distinct().ToListAsync();

            var dbData = await _context.InventoryTransactions
                .Where(it => it.Inventory.ProductId == productId
                          && it.TransactionDate >= startDate
                          && it.TransactionType == "EXPORT"
                          && it.PackageId != null
                          && completedPackageIds.Contains(it.PackageId.Value))
                .GroupBy(it => it.TransactionDate.Date)
                .Select(g => new {
                    Date = g.Key,
                    Quantity = g.Sum(it => Math.Abs(it.QuantityChange))
                })
                .ToListAsync();

            var result = new List<decimal>();
            for (int i = days; i >= 1; i--)
            {
                var date = today.AddDays(-i);
                var match = dbData.FirstOrDefault(d => d.Date == date);
                result.Add(match?.Quantity ?? 0);
            }
            return result;
        }

        public async Task SaveForecastAsync(Forecast forecast)
        {
            await _context.Forecasts.AddAsync(forecast);
            await _context.SaveChangesAsync();
        }

        public async Task<List<Forecast>> GetForecastsByDateAsync(DateTime date)
            => await _context.Forecasts
                .Include(f => f.Product)
                .Where(f => f.ForecastDate.Date == date.Date)
                .ToListAsync();

        public async Task<List<Forecast>> GetAllForecastsAsync()
            => await _context.Forecasts
                .Include(f => f.Product)
                .OrderByDescending(f => f.GeneratedAt)
                .ToListAsync();

        public async Task<List<Forecast>> GetForecastsByProductIdAsync(int productId)
            => await _context.Forecasts
                .Include(f => f.Product)
                .Where(f => f.ProductId == productId)
                .ToListAsync();

        public async Task<List<Forecast>> GetForecastsByDateRangeAsync(DateTime start, DateTime end)
            => await _context.Forecasts
                .Include(f => f.Product)
                .Where(f => f.ForecastDate >= start && f.ForecastDate <= end)
                .ToListAsync();
    }
}