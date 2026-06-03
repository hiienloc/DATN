namespace DOAN4.Dto
{
    public class StaticDto
    {
        public class RevenueByDayDto
        {
            public DateTime Date { get; set; }
            public decimal Revenue { get; set; }
            public int TotalOrders { get; set; }
        }

        public class RevenueByMonthDto
        {
            public int Year { get; set; }
            public int Month { get; set; }
            public decimal Revenue { get; set; }
            public int TotalOrders { get; set; }
        }

        
        public class RevenueByYearDto
        {
            public int Year { get; set; }
            public decimal Revenue { get; set; }
            public int TotalOrders { get; set; }
        }
        public class TopSellingPackageDto
        {
            public int PackageId { get; set; }
            public string PackageCode { get; set; } = string.Empty;
            public string PackageName { get; set; } = string.Empty;
            public string PackageType { get; set; } = string.Empty;
            public decimal Price { get; set; }
            public int TotalSold { get; set; }  
            public decimal Revenue { get; set; }  
        }
        public class DashboardDto
        {
            public decimal RevenueToday { get; set; }
            public decimal RevenueMonth { get; set; }
            public decimal RevenueYear { get; set; }
            public int TotalPackages { get; set; }
            public int LowStockCount { get; set; }  
            public int PendingOrdersCount { get; set; }
            public int TotalCustomersCount { get; set; }
            public List<TopSellingPackageDto> TopPackages { get; set; } = new();
        }

        // ── MỚI: Phục vụ cho StatsManagement.vue ────────────────────────────────
        public class RevenueDetailsResponse
        {
            public decimal TotalRevenue { get; set; }
            public int CompletedOrdersCount { get; set; }
            public decimal AverageOrderValue { get; set; }
            public List<RevenueChartItem> RevenueChart { get; set; } = new();
            public List<PackageSalesItem> PackageSales { get; set; } = new();
        }

        public class RevenueChartItem
        {
            public string TimeLabel { get; set; } = string.Empty;
            public decimal Amount { get; set; }
        }

        public class PackageSalesItem
        {
            public int PackageId { get; set; }
            public string PackageName { get; set; } = string.Empty;
            public int QuantitySold { get; set; }
            public decimal TotalAmount { get; set; }
        }
    }
}
