using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Service
{
    /// <summary>
    /// Lớp OrderService chịu trách nhiệm xử lý các nghiệp vụ liên quan đến đơn hàng (Orders):
    /// - Đặt hàng mới (CreateOrder): trừ số lượng combo, trừ kho lẻ của từng sản phẩm trong combo,
    ///   tính tổng tiền (bao gồm phí ship), khởi tạo trạng thái thanh toán và chạy trong database transaction.
    /// - Hủy đơn hàng (CancelOrder) và cập nhật trạng thái đơn hàng (UpdateOrderStatus).
    /// - Hoàn lại kho (RestoreInventory) số lượng combo và nông sản lẻ nếu đơn hàng bị hủy.
    /// - Xem danh sách đơn hàng toàn hệ thống hoặc theo khách hàng cụ thể.
    /// </summary>
    public class OrderService : IOrderService
    {
        private readonly IOrderRepo _orderRepo;
        private readonly IInventoryRepo _inventoryRepo;

        public OrderService(IOrderRepo orderRepo, IInventoryRepo inventoryRepo)
        {
            _orderRepo = orderRepo;
            _inventoryRepo = inventoryRepo;
        }

        public async Task<OrderDto.OrderResponseDto> CreateOrderAsync(OrderDto.CreateOrderDto orderDto)
        {
            using var transaction = await _orderRepo.BeginTransactionAsync();
            try
            {
                var newOrder = new Order
                {
                    OrderCode = $"ORD-{DateTime.Now:yyyyMMddHHmmss}-{Guid.NewGuid().ToString()[..4]}",
                    UserId = orderDto.UserId,
                    ReceiveName = orderDto.ReceiveName,
                    ReceivePhone = orderDto.ReceivePhone,
                    ReceiveAddress = orderDto.ReceiveAddress,
                    ShipmentPrice = orderDto.ShipmentPrice,
                    OrderDate = DateTime.Now,
                    OrderStatus = "Chờ xác nhận",
                    Items = new List<OrderItem>()
                };

                decimal itemsTotal = 0;

                foreach (var itemDto in orderDto.OrderItems)
                {
                    var package = await _orderRepo.GetPackageAsync(itemDto.PackageId)
                        ?? throw new KeyNotFoundException($"Không tìm thấy gói hàng ID: {itemDto.PackageId}");

                    // 1. Kiểm tra số lượng còn lại
                    int maxAvailable = CalculateMaxAvailable(package);
                    if (maxAvailable < itemDto.Quantity)
                        throw new Exception($"Không đủ hàng! Combo '{package.PackageName}' hiện chỉ có thể chuẩn bị tối đa {maxAvailable} gói.");

                    // 2. Trừ tồn kho lẻ từng sản phẩm trong combo
                    if (package.PackageItems != null && package.PackageItems.Any())
                    {
                        foreach (var pkgItem in package.PackageItems)
                        {
                            if (pkgItem.Product != null && !pkgItem.Product.IsActive)
                            {
                                continue;
                            }

                            var requiredQty = pkgItem.PackageQty * itemDto.Quantity;
                            
                            // Tối ưu hóa: Dùng Eager Loading đã bao gồm trong GetPackageAsync để tránh N+1 Queries
                            var inventory = pkgItem.Product?.Inventory;
                            if (inventory == null)
                            {
                                inventory = await _inventoryRepo.GetByProductIdAsync(pkgItem.ProductId);
                            }

                            if (inventory == null)
                                throw new Exception($"Sản phẩm '{pkgItem.Product?.ProductName}' chưa được cấu hình kho!");

                            if (inventory.QtyInStock < requiredQty)
                                throw new Exception($"Không đủ hàng! '{pkgItem.Product?.ProductName}' trong kho còn {inventory.QtyInStock}kg (Cần {requiredQty}kg).");

                            inventory.QtyInStock -= requiredQty;
                            inventory.LastUpdated = DateTime.Now;

                            await _inventoryRepo.AddTransactionAsync(new InventoryTransaction
                            {
                                InventoryId = inventory.InventoryId,
                                PackageId = package.PackageId,
                                QuantityChange = -requiredQty,
                                TransactionType = "EXPORT",
                                Note = $"Xuất kho cho combo {package.PackageName} (Đơn: {newOrder.OrderCode})",
                                TransactionDate = DateTime.Now
                            });
                        }
                    }

                    // 3. Cập nhật số lượng combo
                    package.MaxQuantity -= itemDto.Quantity;

                    // 4. Tính giá & kiểm tra tính không nhất quán của khuyến mãi
                    decimal finalPrice = package.GetCurrentPrice();

                    if (itemDto.UnitPrice != finalPrice)
                    {
                        throw new InvalidOperationException($"Giá của combo '{package.PackageName}' đã có sự thay đổi. Vui lòng làm mới giỏ hàng.");
                    }

                    newOrder.Items.Add(new OrderItem
                    {
                        PackageId = package.PackageId,
                        OrderQuantity = itemDto.Quantity,
                        OrderPrice = finalPrice
                    });

                    itemsTotal += finalPrice * itemDto.Quantity;
                }

                newOrder.TotalAmount = itemsTotal + newOrder.ShipmentPrice;

                // 5. Khởi tạo Payment
                newOrder.Payment = new Payment
                {
                    PaymentMethod = orderDto.PaymentMethod,
                    PaymentStatus = "Pending",
                    Amount = newOrder.TotalAmount,
                    CreatedAt = DateTime.Now
                };

                await _orderRepo.CreateOrderAsync(newOrder);
                await _orderRepo.SaveChangesAsync();
                await transaction.CommitAsync();

                return MapToResponseDto(newOrder);
            }
            catch (DbUpdateConcurrencyException)
            {
                await transaction.RollbackAsync();
                throw new Exception("Sản phẩm vừa có thay đổi về giá hoặc số lượng. Vui lòng làm mới giỏ hàng.");
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                throw new Exception(ex.Message);
            }
        }

        public async Task<OrderDto.OrderResponseDto> CancelOrderAsync(int id)
        {
            using var transaction = await _orderRepo.BeginTransactionAsync();
            try
            {
                var order = await _orderRepo.GetOrderByIdAsync(id);
                if (order == null) throw new KeyNotFoundException("Không tìm thấy đơn hàng.");

                if (!string.Equals(order.OrderStatus?.Trim(), "Chờ xác nhận", StringComparison.OrdinalIgnoreCase))
                    throw new Exception("Chỉ có thể hủy đơn hàng đang ở trạng thái 'Chờ xác nhận'.");

                await RestoreInventoryAsync(order);

                order.OrderStatus = "Đã hủy";

                if (order.Payment != null)
                {
                    order.Payment.PaymentStatus = "Cancelled";
                    order.Payment.UpdatedAt = DateTime.Now;
                }

                await _orderRepo.SaveChangesAsync();
                await transaction.CommitAsync();

                return MapToResponseDto(order);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                throw new Exception(ex.Message);
            }
        }

        public async Task<List<OrderDto.OrderResponseDto>> GetOrdersAsync()
        {
            var orders = await _orderRepo.GetAllOrdersAsync();
            return orders.Select(MapToResponseDto).ToList();
        }

        public async Task<OrderDto.OrderResponseDto> GetOrderByIdAsync(int orderId)
        {
            var order = await _orderRepo.GetOrderByIdAsync(orderId)
                ?? throw new KeyNotFoundException($"Đơn hàng {orderId} không tồn tại.");
            return MapToResponseDto(order);
        }

        public async Task<List<OrderDto.OrderResponseDto>> GetOrdersByUserIdAsync(int userId)
        {
            var orders = await _orderRepo.GetOrdersByUserIdAsync(userId);
            return orders.Select(MapToResponseDto).ToList();
        }

        public async Task<OrderDto.OrderResponseDto> UpdateOrderStatusAsync(int id, string status)
        {
            var order = await _orderRepo.GetOrderByIdAsync(id)
                ?? throw new KeyNotFoundException("Không tìm thấy đơn hàng.");

            var cleanStatus = status?.Trim();
            
            // Chuẩn hóa trạng thái từ Tiếng Anh sang Tiếng Việt
            var targetStatus = cleanStatus;
            if (string.Equals(targetStatus, "cancelled", StringComparison.OrdinalIgnoreCase))
                targetStatus = "Đã hủy";
            else if (string.Equals(targetStatus, "completed", StringComparison.OrdinalIgnoreCase))
                targetStatus = "Hoàn thành";
            else if (string.Equals(targetStatus, "pending", StringComparison.OrdinalIgnoreCase))
                targetStatus = "Chờ xác nhận";

            var currentStatus = order.OrderStatus?.Trim();

            // Nếu trạng thái đích trùng với trạng thái hiện tại thì trả về luôn
            if (string.Equals(currentStatus, targetStatus, StringComparison.OrdinalIgnoreCase))
            {
                return MapToResponseDto(order);
            }

            // Một khi đơn hàng đã Hoàn thành hoặc Đã hủy thì không thể thay đổi trạng thái
            if (string.Equals(currentStatus, "Hoàn thành", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("Đơn hàng đã ở trạng thái 'Hoàn thành', không thể thay đổi trạng thái.");
            }
            if (string.Equals(currentStatus, "Đã hủy", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("Đơn hàng đã bị 'Hủy', không thể thay đổi trạng thái.");
            }

            // Chỉ cho phép chuyển từ "Chờ xác nhận" sang "Hoàn thành" hoặc "Đã hủy"
            if (!string.Equals(currentStatus, "Chờ xác nhận", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException($"Không thể chuyển trạng thái từ '{currentStatus}' sang '{targetStatus}'.");
            }

            if (!string.Equals(targetStatus, "Hoàn thành", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(targetStatus, "Đã hủy", StringComparison.OrdinalIgnoreCase))
            {
                throw new ArgumentException($"Trạng thái mục tiêu '{status}' không hợp lệ.");
            }

            using var transaction = await _orderRepo.BeginTransactionAsync();
            try
            {
                if (string.Equals(targetStatus, "Đã hủy", StringComparison.OrdinalIgnoreCase))
                {
                    await RestoreInventoryAsync(order);
                    if (order.Payment != null)
                    {
                        order.Payment.PaymentStatus = "Cancelled";
                        order.Payment.UpdatedAt = DateTime.Now;
                    }
                }
                else if (string.Equals(targetStatus, "Hoàn thành", StringComparison.OrdinalIgnoreCase))
                {
                    if (order.Payment != null)
                    {
                        order.Payment.PaymentStatus = "Paid";
                        order.Payment.UpdatedAt = DateTime.Now;
                    }
                }

                order.OrderStatus = targetStatus;

                await _orderRepo.SaveChangesAsync();
                await transaction.CommitAsync();
                return MapToResponseDto(order);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                throw new Exception(ex.Message);
            }
        }

        // ── Private helpers ───────────────────────────────────────────────
        private static int CalculateMaxAvailable(Package p)
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

        private async Task RestoreInventoryAsync(Order order)
        {
            if (string.Equals(order.OrderStatus?.Trim(), "Đã hủy", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            // Đánh dấu trạng thái ngay lập tức ở bộ nhớ để ngăn chặn các lời gọi đồng thời làm cộng tồn kho nhiều lần
            order.OrderStatus = "Đã hủy";

            foreach (var item in order.Items)
            {
                var package = item.Package;
                if (package == null) continue;

                // 1. Hoàn lại số lượng combo
                package.MaxQuantity += item.OrderQuantity;

                // 2. Hoàn lại tồn kho lẻ
                if (package.PackageItems != null && package.PackageItems.Any())
                {
                    foreach (var pkgItem in package.PackageItems)
                    {
                        if (pkgItem.Product != null && !pkgItem.Product.IsActive)
                        {
                            continue;
                        }

                        var inventory = pkgItem.Product?.Inventory
                            ?? await _inventoryRepo.GetByProductIdAsync(pkgItem.ProductId);

                        if (inventory == null) continue;

                        var refundQty = pkgItem.PackageQty * item.OrderQuantity;

                        inventory.QtyInStock += refundQty;
                        inventory.LastUpdated = DateTime.Now;

                        await _inventoryRepo.AddTransactionAsync(new InventoryTransaction
                        {
                            InventoryId = inventory.InventoryId,
                            PackageId = package.PackageId,
                            QuantityChange = refundQty,
                            TransactionType = "IMPORT",
                            Note = $"Hoàn tồn kho lẻ do hủy đơn {order.OrderCode}",
                            TransactionDate = DateTime.Now
                        });
                    }
                }
            }
        }

        private OrderDto.OrderResponseDto MapToResponseDto(Order order)
        {
            return new OrderDto.OrderResponseDto
            {
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                UserId = order.UserId,
                TotalAmount = order.TotalAmount,
                ShipmentPrice = order.ShipmentPrice,
                ReceiveName = order.ReceiveName,
                ReceivePhone = order.ReceivePhone,
                ReceiveAddress = order.ReceiveAddress,
                OrderStatus = order.OrderStatus,
                OrderDate = order.OrderDate,
                OrderItems = order.Items?.Select(oi => new OrderDto.OrderItemDto
                {
                    PackageId = oi.PackageId,
                    PackageName = oi.Package?.PackageName ?? "Sản phẩm",
                    ImageUrl = oi.Package?.ImageUrl ?? string.Empty,
                    Quantity = oi.OrderQuantity,
                    UnitPrice = oi.OrderPrice
                }).ToList() ?? new List<OrderDto.OrderItemDto>(),

                Payment = order.Payment != null ? new OrderDto.PaymentResponseDto
                {
                    PaymentId = order.Payment.PaymentId,
                    OrderId = order.Payment.OrderId,
                    PaymentMethod = order.Payment.PaymentMethod,
                    Amount = order.Payment.Amount,
                    PaymentStatus = order.Payment.PaymentStatus,
                    CreatedAt = order.Payment.CreatedAt,
                    UpdatedAt = order.Payment.UpdatedAt,
                    Transactions = order.Payment.Transactions?.Select(t => new OrderDto.TransactionDto
                    {
                        TransactionId = t.TransactionId,
                        TransactionNo = t.TransactionNo,
                        BankCode = t.BankCode,
                        ResponseCode = t.ResponseCode,
                        Status = t.Status,
                        TransactionDate = t.TransactionDate
                    }).ToList() ?? new List<OrderDto.TransactionDto>()
                } : null
            };
        }
    }
}