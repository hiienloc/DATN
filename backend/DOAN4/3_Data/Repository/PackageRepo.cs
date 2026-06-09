using DOAN4.Data;
using DOAN4.IRepository;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Repository
{
    public class PackageRepo : IPackageRepo
    {
        private readonly AppDbContext _context;

        public PackageRepo(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Package>> GetAllPackagesAsync()
        {
            return await _context.Packages
                .Include(p => p.PackageItems)
                    .ThenInclude(pi => pi.Product)
                        .ThenInclude(pr => pr.Inventory)
                .ToListAsync();
        }

        public async Task<Package?> GetPackageByIdAsync(int packageId)
        {
            return await _context.Packages
                .Include(p => p.PackageItems)
                    .ThenInclude(pi => pi.Product)
                        .ThenInclude(pr => pr.Inventory)
                .FirstOrDefaultAsync(p => p.PackageId == packageId);
        }

        public async Task AddPackageAsync(Package package)
        {
            _context.Packages.Add(package);
            await _context.SaveChangesAsync();
        }

        public async Task UpdatePackageAsync(Package package)
        {
            // Tìm và xoá toàn bộ package items cũ trực tiếp trong CSDL để dọn đường cho list mới
            // Tránh lỗi "severed relationship" hoặc vi phạm khoá ngoại của EF Core khi gán lại list
            var existingItems = await _context.PackageItems
                .Where(pi => pi.PackageId == package.PackageId)
                .ToListAsync();

            if (existingItems.Any())
                _context.PackageItems.RemoveRange(existingItems);

            _context.Packages.Update(package);
            await _context.SaveChangesAsync();
        }

        public async Task LockPackageAsync(int packageId)
        {
            var package = await _context.Packages
                .FirstOrDefaultAsync(p => p.PackageId == packageId);

            if (package == null)
                throw new KeyNotFoundException($"Không tìm thấy package với ID {packageId}");

            package.IsActive = false;
            await _context.SaveChangesAsync();
        }

    }
}