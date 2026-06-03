using DOAN4.Models;

public interface IPackageRepo
{
    Task<List<Package>> GetAllPackagesAsync();
    Task<Package> GetPackageByIdAsync(int packageId);
    Task AddPackageAsync(Package package);
    Task UpdatePackageAsync(Package package);
    Task LockPackageAsync(int packageId);
}