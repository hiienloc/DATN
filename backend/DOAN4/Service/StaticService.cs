using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;

namespace DOAN4.Service
{
    public class StaticService : IStaticService

    {
        private readonly IStaticRepo _staticRepository;
        public StaticService(IStaticRepo staticRepository)
        {
            _staticRepository = staticRepository;
        }

        public async Task<StaticDto.DashboardDto> GetDashboardAsync()
        {
          var dashboardData = await _staticRepository.GetDashboardAsync();
          return dashboardData;
        }

        public Task<StaticDto.RevenueByDayDto> GetRevenueByDayAsync(DateTime date)
        {
           var dayRevenue = _staticRepository.GetRevenueByDayAsync(date);
            return dayRevenue;
        }

        public async Task<StaticDto.RevenueByMonthDto> GetRevenueByMonthAsync(int year, int month)
        {
           var monthRevenue = await _staticRepository.GetRevenueByMonthAsync(year, month);
            return monthRevenue;
        }

        public async Task<StaticDto.RevenueByYearDto> GetRevenueByYearAsync(int year)
        {
            var yearRevenue = await _staticRepository.GetRevenueByYearAsync(year);
            return yearRevenue;
        }

        public async Task<List<StaticDto.TopSellingPackageDto>> GetTopSellingPackagesAsync(int top)
        {
            var topPackages = await     _staticRepository.GetTopSellingPackagesAsync(top);
            return topPackages;
        }

        public async Task<StaticDto.RevenueDetailsResponse> GetRevenueDetailsAsync(DateTime? fromDate, DateTime? toDate, string groupBy)
        {
            return await _staticRepository.GetRevenueDetailsAsync(fromDate, toDate, groupBy);
        }
    }
}
