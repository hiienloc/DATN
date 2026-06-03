using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Service
{
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

                decimal totalAmount = newOrder.ShipmentPrice;

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
                            var inventory = await _inventoryRepo.GetByProductIdAsync(pkgItem.ProductId);

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

                    // 4. Tính giá
                    bool isPromoActive = package.Discount > 0
                        && package.StartDate <= DateTime.Now
                        && DateTime.Now <= package.EndDate;

                    decimal finalPrice = isPromoActive ? package.Discount : package.Price;

                    newOrder.Items.Add(new OrderItem
                    {
                        PackageId = package.PackageId,
                        OrderQuantity = itemDto.Quantity,
                        OrderPrice = finalPrice
                    });

                    totalAmount += finalPrice * itemDto.Quantity;
                }

                newOrder.TotalAmount = totalAmount;

                // 5. Khởi tạo Payment
                newOrder.Payment = new Payment
                {
                    PaymentMethod = orderDto.PaymentMethod,
                    PaymentStatus = "Pending",
                    Amount = totalAmount,
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

            using var transaction = await _orderRepo.BeginTransactionAsync();
            try
            {
                if (string.Equals(cleanStatus, "Đã hủy", StringComparison.OrdinalIgnoreCase) || 
                    string.Equals(cleanStatus, "cancelled", StringComparison.OrdinalIgnoreCase))
                {
                    await RestoreInventoryAsync(order);
                    if (order.Payment != null)
                    {
                        order.Payment.PaymentStatus = "Cancelled";
                        order.Payment.UpdatedAt = DateTime.Now;
                    }
                }
                else if (string.Equals(cleanStatus, "Hoàn thành", StringComparison.OrdinalIgnoreCase) || 
                         string.Equals(cleanStatus, "completed", StringComparison.OrdinalIgnoreCase))
                {
                    if (order.Payment != null)
                    {
                        order.Payment.PaymentStatus = "Paid";
                        order.Payment.UpdatedAt = DateTime.Now;
                    }
                }

                order.OrderStatus = status;

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