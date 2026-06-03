using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;

namespace DOAN4.Service
{
    public class PackageService : IPackageService
    {
        private readonly IPackageRepo _packageRepo;

        public PackageService(IPackageRepo packageRepo)
        {
            _packageRepo = packageRepo;
        }

        public async Task<List<PackageDto.PackageResponseDto>> GetAllPackagesAsync()
        {
            var packages = await _packageRepo.GetAllPackagesAsync();
            return packages.Select(MapToResponseDto).ToList();
        }

        public async Task<PackageDto.PackageResponseDto> GetPackageByIdAsync(int packageId)
        {
            var package = await _packageRepo.GetPackageByIdAsync(packageId)
                ?? throw new KeyNotFoundException($"Không tìm thấy package với ID {packageId}");

            return MapToResponseDto(package);
        }

        public async Task AddPackageAsync(PackageDto.CreatePackageDto dto)
        {
            var allPackages = await _packageRepo.GetAllPackagesAsync();

            if (allPackages.Any(p => p.PackageCode.Trim().ToLower() == dto.PackageCode.Trim().ToLower()))
                throw new InvalidOperationException($"Mã combo '{dto.PackageCode}' đã tồn tại.");

            if (allPackages.Any(p => p.PackageName.Trim().ToLower() == dto.PackageName.Trim().ToLower()))
                throw new InvalidOperationException($"Tên combo '{dto.PackageName}' đã tồn tại.");

            var startDate = dto.StartDate ?? DateTime.Now;
            var endDate = dto.EndDate ?? DateTime.Now.AddYears(10);

            if (endDate <= startDate)
                throw new InvalidOperationException("Ngày kết thúc phải sau ngày bắt đầu.");

            var package = new Models.Package
            {
                PackageCode = dto.PackageCode,
                PackageName = dto.PackageName,
                ImageUrl = dto.ImageUrl ?? "/images/default_package.png",
                Description = dto.Description,
                Price = dto.Price,
                StartDate = startDate,
                EndDate = endDate,
                Discount = dto.Discount,
                MaxQuantity = dto.MaxQuantity,
                IsActive = dto.IsActive,
                PackageItems = dto.Items.Select(i => new Models.PackageItem
                {
                    ProductId = i.ProductId,
                    PackageQty = i.Quantity
                }).ToList()
            };

            await _packageRepo.AddPackageAsync(package);
        }

        public async Task UpdatePackageAsync(PackageDto.UpdatePackageDto dto)
        {
            var package = await _packageRepo.GetPackageByIdAsync(dto.PackageId)
                ?? throw new KeyNotFoundException($"Không tìm thấy package với ID {dto.PackageId}");

            var allPackages = await _packageRepo.GetAllPackagesAsync();

            if (allPackages.Any(p => p.PackageId != dto.PackageId
                                  && p.PackageCode.Trim().ToLower() == dto.PackageCode.Trim().ToLower()))
                throw new InvalidOperationException($"Mã combo '{dto.PackageCode}' đã tồn tại.");

            if (allPackages.Any(p => p.PackageId != dto.PackageId
                                  && p.PackageName.Trim().ToLower() == dto.PackageName.Trim().ToLower()))
                throw new InvalidOperationException($"Tên combo '{dto.PackageName}' đã tồn tại.");

            var startDate = dto.StartDate ?? package.StartDate;
            var endDate = dto.EndDate ?? package.EndDate;

            if (endDate <= startDate)
                throw new InvalidOperationException("Ngày kết thúc phải sau ngày bắt đầu.");

            package.PackageCode = dto.PackageCode;
            package.PackageName = dto.PackageName;
            package.Description = dto.Description;
            package.Price = dto.Price;
            package.StartDate = startDate;
            package.EndDate = endDate;
            package.Discount = dto.Discount;
            package.MaxQuantity = dto.MaxQuantity;
            package.IsActive = dto.IsActive;

            if (!string.IsNullOrEmpty(dto.ImageUrl))
                package.ImageUrl = dto.ImageUrl;

            package.PackageItems = dto.Items.Select(i => new Models.PackageItem
            {
                PackageId = package.PackageId,
                ProductId = i.ProductId,
                PackageQty = i.Quantity
            }).ToList();

            await _packageRepo.UpdatePackageAsync(package);
        }

        public async Task LockPackageAsync(int packageId)
        {
            await _packageRepo.LockPackageAsync(packageId);
        }

        // ── Private helpers ───────────────────────────────────────────────
        private static PackageDto.PackageResponseDto MapToResponseDto(Models.Package p) =>
            new()
            {
                PackageId = p.PackageId,
                PackageCode = p.PackageCode,
                PackageName = p.PackageName,
                ImageUrl = p.ImageUrl,
                Description = p.Description,
                Price = p.Price,
                StartDate = p.StartDate,
                EndDate = p.EndDate,
                Discount = p.Discount,
                MaxQuantity = CalculateMaxAvailable(p),
                IsActive = p.IsActive,
                Items = p.PackageItems != null
                    ? p.PackageItems
                        .Where(pi => pi.Product == null || pi.Product.IsActive)
                        .Select(pi => new PackageDto.PackageItemDto
                        {
                            ProductId = pi.ProductId,
                            Quantity = pi.PackageQty,
                            ProductName = pi.Product?.ProductName
                        }).ToList()
                    : new List<PackageDto.PackageItemDto>()
            };

        private static int CalculateMaxAvailable(Models.Package p)
        {
            if (p.PackageItems == null || !p.PackageItems.Any())
                return 0;

            int maxByInventory = int.MaxValue;
            bool hasActiveProducts = false;
            foreach (var pi in p.PackageItems)
            {
                if (pi.Product != null && !pi.Product.IsActive)
                {
                    continue;
                }

                hasActiveProducts = true;

                if (pi.Product?.Inventory != null && pi.PackageQty > 0)
                {
                    int possible = (int)(pi.Product.Inventory.QtyInStock / pi.PackageQty);
                    if (possible < maxByInventory)
                        maxByInventory = possible;
                }
                else
                {
                    maxByInventory = 0;
                }
            }

            if (!hasActiveProducts)
                return 0;

            int finalMax = Math.Min(p.MaxQuantity, maxByInventory);
            return finalMax < 0 ? 0 : finalMax;
        }
    }
}