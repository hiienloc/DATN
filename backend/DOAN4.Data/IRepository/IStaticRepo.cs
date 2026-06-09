using DOAN4.Dto;

namespace DOAN4.IRepository
{
    public interface IStaticRepo
    {
        Task<StaticDto.DashboardDto> GetDashboardAsync();
        Task<StaticDto.RevenueByDayDto> GetRevenueByDayAsync(DateTime date);
        Task<StaticDto.RevenueByMonthDto> GetRevenueByMonthAsync(int year, int month);
        Task<StaticDto.RevenueByYearDto> GetRevenueByYearAsync(int year);
        Task<List<StaticDto.TopSellingPackageDto>> GetTopSellingPackagesAsync(int top);
        Task<StaticDto.RevenueDetailsResponse> GetRevenueDetailsAsync(DateTime? fromDate, DateTime? toDate, string groupBy);
    }
}
