using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using DOAN4.Models;

namespace DOAN4.Service
{
    /// <summary>
    /// Lớp CartService quản lý các nghiệp vụ liên quan đến giỏ hàng (Shopping Cart):
    /// - Lấy thông tin giỏ hàng hiện tại của khách hàng.
    /// - Thêm combo nông sản (Package) vào giỏ hàng và kiểm tra tính hợp lệ của tồn kho.
    /// - Cập nhật số lượng mặt hàng trong giỏ, áp dụng giá khuyến mãi (Discount) nếu có.
    /// - Xóa mặt hàng khỏi giỏ hoặc làm rỗng toàn bộ giỏ hàng.
    /// </summary>
    public class CartService : ICartService
    {
        private readonly ICartRepo _repo;
        private readonly IPackageRepo _packageRepo;

        public CartService(ICartRepo repo, IPackageRepo packageRepo)
        {
            _repo = repo;
            _packageRepo = packageRepo;
        }

        public async Task<CartDto.CartResponseDto> GetCartByUserIdAsync(int userId)
        {
            var cart = await _repo.GetCartByUserIdAsync(userId);
            if (cart == null) return new CartDto.CartResponseDto { UserId = userId };
            return MapToCartResponseDto(cart);
        }

        public async Task AddToCartAsync(int userId, CartDto.AddToCartDto dto)
        {
            // 1. Lấy package kèm inventory
            var package = await _packageRepo.GetPackageByIdAsync(dto.PackageId);
            if (package == null)
                throw new KeyNotFoundException("Package không tồn tại.");

            // 2. Check tồn kho (cộng cả số lượng đang có trong cart)
            var existingItem = await _repo.GetCartItemAsync(userId, dto.PackageId);
            int totalQty = (existingItem?.CartQuantity ?? 0) + dto.Quantity;
            CheckInventory(package, totalQty);

            // 3. Lấy cart, tạo mới nếu chưa có
            var cart = await _repo.GetCartByUserIdAsync(userId);
            if (cart == null)
            {
                cart = new Cart { UserId = userId };
                await _repo.AddCartAsync(cart);
                await _repo.SaveChangesAsync();
            }

            // 4. Tính giá
            decimal finalPrice = package.GetCurrentPrice();

            // 5. Update hoặc thêm mới item
            if (existingItem != null)
            {
                existingItem.CartQuantity += dto.Quantity;
                existingItem.CartPrice = finalPrice;
                await _repo.UpdateCartItemAsync(existingItem);
            }
            else
            {
                var newItem = new CartItem
                {
                    CartId = cart.CartId,
                    PackageId = dto.PackageId,
                    CartQuantity = dto.Quantity,
                    CartPrice = finalPrice
                };
                await _repo.AddCartItemAsync(newItem);
            }

            // 6. Lưu
            await _repo.SaveChangesAsync();
        }

        public async Task UpdateCartAsync(int userId, CartDto.UpdateQuantityDto dto)
        {
            var cartItem = await _repo.GetCartItemAsync(userId, dto.PackageId);
            if (cartItem == null)
                throw new KeyNotFoundException("Không tìm thấy sản phẩm trong giỏ hàng.");

            if (dto.Quantity <= 0)
                throw new ArgumentException("Số lượng phải lớn hơn 0.");

            // Check tồn kho khi update số lượng
            var package = await _packageRepo.GetPackageByIdAsync(cartItem.PackageId);
            if (package != null)
                CheckInventory(package, dto.Quantity);

            cartItem.CartQuantity = dto.Quantity;
            await _repo.UpdateCartItemAsync(cartItem);
            await _repo.SaveChangesAsync();
        }

        public async Task RemoveFromCartAsync(int cartItemId)
        {
            var cartItem = await _repo.GetCartItemByIdAsync(cartItemId);
            if (cartItem == null)
                throw new KeyNotFoundException("Không tìm thấy sản phẩm trong giỏ hàng.");

            await _repo.RemoveCartItemAsync(cartItem);
            await _repo.SaveChangesAsync();
        }

        public async Task ClearCartAsync(int userId)
        {
            await _repo.ClearCartAsync(userId);
            await _repo.SaveChangesAsync();
        }


        
        private static void CheckInventory(Models.Package package, int requestedQty)
        {
            if (package.PackageItems == null || !package.PackageItems.Any())
                throw new InvalidOperationException("Package không có sản phẩm.");

            foreach (var pi in package.PackageItems)
            {
                if (pi.Product != null && !pi.Product.IsActive)
                {
                    continue;
                }

                if (pi.Product?.Inventory == null)
                    throw new InvalidOperationException(
                        $"Sản phẩm '{pi.Product?.ProductName}' không có thông tin tồn kho.");

                int possible = (int)(pi.Product.Inventory.QtyInStock / pi.PackageQty);
                if (requestedQty > possible)
                    throw new InvalidOperationException(
                        $"Sản phẩm '{pi.Product.ProductName}' không đủ tồn kho. Còn tối đa {possible} combo.");
            }
        }

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

        private CartDto.CartResponseDto MapToCartResponseDto(Cart cart) =>
            new()
            {
                CartId = cart.CartId,
                UserId = cart.UserId,
                Items = cart.CartItems?
                             .Select(MapToCartItemDto)
                             .ToList() ?? new List<CartDto.CartItemDto>()
            };

        private static CartDto.CartItemDto MapToCartItemDto(CartItem item)
        {
            decimal displayPrice = item.CartPrice;
            if (item.Package != null)
            {
                displayPrice = item.Package.GetCurrentPrice();
            }

            return new CartDto.CartItemDto
            {
                CartItemId = item.CartItemId,
                PackageId = item.PackageId,
                PackageName = item.Package?.PackageName ?? string.Empty,
                ImageUrl = item.Package?.ImageUrl ?? string.Empty,
                Price = displayPrice,
                Quantity = item.CartQuantity,
                MaxQuantity = item.Package != null ? CalculateMaxAvailable(item.Package) : 0
            };
        }
    }
}