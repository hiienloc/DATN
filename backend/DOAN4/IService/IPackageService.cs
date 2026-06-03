using DOAN4.Dto;

namespace DOAN4.IService
{
    public interface IPackageService
    {
        Task<List<PackageDto.PackageResponseDto>> GetAllPackagesAsync();
        Task<PackageDto.PackageResponseDto> GetPackageByIdAsync(int packageId);
        Task AddPackageAsync(PackageDto.CreatePackageDto packageDto);
        Task UpdatePackageAsync(PackageDto.UpdatePackageDto packageDto);
        Task LockPackageAsync(int packageId);
       // Task<int> CalculateMaxAvailableAsync(int packageId);
    }
}
