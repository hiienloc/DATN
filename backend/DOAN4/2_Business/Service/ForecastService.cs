using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;
using Microsoft.Extensions.Logging;
using DOAN4.Models;

namespace DOAN4.Service
{
    public class ForecastService : IForecastService
    {
        private readonly IForecastRepo _forecastRepository;
        private readonly IInventoryRepo _inventoryRepo;
        private readonly IGeminiService _geminiService;
        private readonly ILogger<ForecastService> _logger;

        private const string DefaultUnit = "đơn vị";

        public ForecastService(
            IForecastRepo forecastRepository,
            IInventoryRepo inventoryRepo,
            IGeminiService geminiService,
            ILogger<ForecastService> logger)
        {
            _forecastRepository = forecastRepository;
            _inventoryRepo = inventoryRepo;
            _geminiService = geminiService;
            _logger = logger;
        }

        // Tạo forecast hàng ngày cho tất cả sản phẩm (chạy bởi background job)
        // GetAllProductsAsync() đã tự filter — chỉ lấy product có trong đơn hoàn thành
        public async Task GenerateDailyForecastAsync()
        {
            var products = await _forecastRepository.GetAllProductsAsync();
            var today = DateTime.Today;

            int successCount = 0;
            int skipCount = 0;
            int failCount = 0;

            foreach (var product in products)
            {
                try
                {
                    var forecast = await BuildForecastAsync(product, today);
                    await _forecastRepository.SaveForecastAsync(forecast);
                    successCount++;
                }
                catch (InvalidOperationException ex)
                {
                    // Lỗi nghiệp vụ (thiếu data) — không phải lỗi hệ thống
                    skipCount++;
                    _logger.LogWarning(
                        "Bỏ qua dự báo '{ProductName}': {Reason}",
                        product.ProductName, ex.Message);
                }
                catch (Exception ex)
                {
                    failCount++;
                    _logger.LogError(ex,
                        "Lỗi hệ thống khi tạo forecast cho sản phẩm ID={ProductId}.",
                        product.ProductId);
                }
            }

            _logger.LogInformation(
                "GenerateDailyForecastAsync hoàn tất: {Success} thành công, " +
                "{Skip} bỏ qua (thiếu data), {Fail} lỗi hệ thống.",
                successCount, skipCount, failCount);
        }

        public async Task<List<ForecastDto.ForecastResponseDto>> GetDailyForecastAsync()
        {
            // ForecastDate = today + forecastDays → query ngày mai để lấy dự báo gần nhất
            var tomorrow = DateTime.Today.AddDays(1);
            var forecasts = await _forecastRepository.GetForecastsByDateAsync(tomorrow);
            return forecasts.Select(MapToResponseDto).ToList();
        }

        public async Task<List<ForecastDto.ForecastResponseDto>> GetForecastsAsync()
        {
            var results = await _forecastRepository.GetAllForecastsAsync();
            return results.Select(MapToResponseDto).ToList();
        }

        public async Task<List<ForecastDto.ForecastResponseDto>> GetProductForecastAsync(int productId)
        {
            var forecasts = await _forecastRepository.GetForecastsByProductIdAsync(productId);
            return forecasts.Select(MapToResponseDto).ToList();
        }

        public async Task<List<ForecastDto.ForecastResponseDto>> GetWeeklyForecastAsync()
        {
            var today = DateTime.Today;
            var nextWeek = today.AddDays(7);
            var forecasts = await _forecastRepository.GetForecastsByDateRangeAsync(today, nextWeek);
            return forecasts.Select(MapToResponseDto).ToList();
        }

        // Tạo forecast thủ công cho 1 sản phẩm cụ thể (gọi từ API)
        public async Task<ForecastDto.ForecastResponseDto> GenerateProductForecastAsync(int productId)
        {
            // Bước 1: Kiểm tra product có tồn tại trong hệ thống không
            var inventory = await _inventoryRepo.GetByProductIdAsync(productId);
            if (inventory?.Product == null)
            {
                _logger.LogWarning("Không tìm thấy sản phẩm ID={ProductId}.", productId);
                throw new KeyNotFoundException($"Không tìm thấy sản phẩm với ID: {productId}");
            }

            var product = inventory.Product;

            // Bước 2: Kiểm tra product có nằm trong ít nhất 1 đơn hàng hoàn thành không
            
            var isQualified = await _forecastRepository.IsProductQualifiedForForecastAsync(productId);
            if (!isQualified)
            {
                _logger.LogWarning(
                    "Sản phẩm '{ProductName}' (ID={ProductId}) chưa có trong đơn hàng hoàn thành.",
                    product.ProductName, productId);

                throw new InvalidOperationException(
                    $"Sản phẩm '{product.ProductName}' chưa có trong bất kỳ đơn hàng nào " +
                    $"ở trạng thái 'Hoàn thành'. Cần ít nhất 1 đơn hoàn thành để chạy dự báo AI.");
            }

            // Bước 3: Đủ điều kiện → chạy forecast
            var today = DateTime.Today;
            var forecast = await BuildForecastAsync(product, today);
            await _forecastRepository.SaveForecastAsync(forecast);

            forecast.Product = product;
            return MapToResponseDto(forecast);
        }
        // Hàm cốt lõi xây dựng thông tin dự báo cho sản phẩm
        private async Task<DOAN4.Models.Forecast> BuildForecastAsync(Product product, DateTime today)
        {
            // BƯỚC 1: LẤY LỊCH SỬ TIÊU THỤ VÀ XUẤT KHO TRONG 30 NGÀY GẦN NHẤT
            // - salesHistory: Lượng bán thực tế cho khách hàng từ các đơn hàng đã 'Hoàn thành'
            // - exportHistory: Lượng xuất kho thực tế (bao gồm cả hao hụt, hỏng hóc, combo quà tặng...)
            var salesHistory = await _forecastRepository.GetProductConsumptionHistoryAsync(product.ProductId, 30);
            var exportHistory = await _forecastRepository.GetProductExportHistoryAsync(product.ProductId, 30);

            if (!exportHistory.Any())
            {
                _logger.LogWarning(
                    "Sản phẩm '{ProductName}': không có lịch sử xuất kho. " +
                    "Dự báo chỉ dựa trên đơn hàng hoàn thành.",
                    product.ProductName);
            }

            // Tính số lượng trung bình tiêu thụ mỗi ngày của 30 ngày qua
            decimal avgSales = salesHistory.Any() ? salesHistory.Average() : 0;
            decimal avgExports = exportHistory.Any() ? exportHistory.Average() : 0;

            // BƯỚC 2: XÁC ĐỊNH CHU KỲ DỰ BÁO (3, 5, hoặc 7 ngày) DỰA TRÊN TẦN SUẤT GIAO DỊCH
            // - Đếm số ngày có phát sinh giao dịch (> 0) trong 30 ngày qua
            int activeSalesDays = salesHistory.Count(q => q > 0);
            int activeExportDays = exportHistory.Count(q => q > 0);
            // - Lấy tần suất hoạt động lớn nhất làm đại diện
            int maxFrequency = Math.Max(activeSalesDays, activeExportDays);
            
            // - Phân loại chu kỳ dự báo:
            //   + Bán rất chạy (tần suất >= 20 ngày): Dự báo ngắn hạn 3 ngày (xoay vòng kho nhanh, tránh hỏng nông sản)
            //   + Bán vừa (tần suất >= 10 ngày): Dự báo trung hạn 5 ngày
            //   + Bán chậm/mới bán (tần suất < 10 ngày): Dự báo dài hạn 7 ngày (nhập định kỳ hàng tuần để tiết kiệm chi phí vận hành)
            int forecastDays = maxFrequency switch
            {
                >= 20 => 3,
                >= 10 => 5,
                _ => 7
            };

            string unit = product.Unit ?? DefaultUnit;

            // BƯỚC 3: GỌI GEMINI AI ĐỂ DỰ BÁO NHU CẦU TIÊU THỤ TRONG N NGÀY TỚI
            // Truyền tên sản phẩm, lịch sử bán, lịch sử xuất kho, đơn vị tính và số ngày cần dự báo
            decimal predictedQty = await _geminiService.ForecastQuantityWithWarehouseAsync(
                product.ProductName, salesHistory, exportHistory, unit, forecastDays);

            // BƯỚC 4: CƠ CHẾ DỰ PHÒNG (FALLBACK) KHI AI THẤT BẠI
            // Nếu AI gặp lỗi (mất mạng, hết quota API) hoặc trả về lượng dự báo <= 0:
            if (predictedQty <= 0)
            {
                // Chọn giá trị trung bình ngày lớn nhất giữa bán và xuất kho
                decimal baseAvg = Math.Max(avgSales, avgExports);

                if (baseAvg <= 0)
                {
                    // Hoàn toàn không có dữ liệu lịch sử tiêu dùng nào
                    _logger.LogWarning(
                        "Sản phẩm '{ProductName}': AI thất bại và không có dữ liệu lịch sử để fallback. " +
                        "predictedQty = 0.",
                        product.ProductName);
                }
                else
                {
                    // Công thức fallback: Lượng TB ngày * Hệ số tăng trưởng 1.1 (tăng 10% an toàn) * Số ngày dự báo
                    predictedQty = baseAvg * 1.1m * forecastDays;
                    _logger.LogWarning(
                        "Dùng fallback cho '{ProductName}': " +
                        "avgSales={AvgSales}, avgExports={AvgExports}, " +
                        "predictedQty={Pred} trong {Days} ngày.",
                        product.ProductName, avgSales, avgExports, predictedQty, forecastDays);
                }
            }

            // BƯỚC 5: TÍNH TOÁN LƯỢNG ĐỀ XUẤT NHẬP HÀNG (SUGGEST RESTOCK)
            // Lấy lượng hàng tồn kho thực tế hiện tại
            var inventory = await _inventoryRepo.GetByProductIdAsync(product.ProductId);
            decimal currentStock = inventory?.QtyInStock ?? 0;

            // - Tồn kho an toàn (Safety Stock): Chiếm 20% lượng tiêu dùng dự báo để dự phòng trễ hàng/tăng nhu cầu đột xuất
            decimal safetyStock = predictedQty * 0.2m;
            // - Tồn kho mục tiêu (Target Stock): Lượng tiêu dùng dự báo + lượng an toàn
            decimal targetStock = predictedQty + safetyStock;
            // - Lượng gợi ý nhập thêm = Tồn kho mục tiêu - Tồn kho hiện tại (Nếu tồn kho hiện tại nhiều hơn mục tiêu thì trả về 0)
            decimal suggestStock = predictedQty > 0
                ? Math.Max(0, targetStock - currentStock)
                : 0;

            return new DOAN4.Models.Forecast
            {
                ProductId = product.ProductId,
                ForecastType = forecastDays switch
                {
                    3 => "3 Days",
                    5 => "5 Days",
                    _ => "Weekly"
                },
                AvgDailySales = avgSales,
                PredictQuantity = predictedQty,
                CurrentStock = currentStock,
                SuggestReStock = suggestStock,
                ForecastDate = today.AddDays(forecastDays),
                GeneratedAt = DateTime.UtcNow
            };
        }
        public async Task<ForecastDto.ActualHistoryDto> GetActualHistoryAsync(int productId)
        {
            var inventory = await _inventoryRepo.GetByProductIdAsync(productId);
            if (inventory == null)
            {
                throw new KeyNotFoundException($"Không tìm thấy sản phẩm với ID {productId}");
            }
            var salesHistory = await _forecastRepository.GetProductConsumptionHistoryAsync(productId, 30);
            var exportHistory = await _forecastRepository.GetProductExportHistoryAsync(productId, 30);
            return new ForecastDto.ActualHistoryDto
            {
                SalesHistory = salesHistory,
                ExportHistory = exportHistory
            };
        }
    

        private ForecastDto.ForecastResponseDto MapToResponseDto(DOAN4.Models.Forecast f)
        {
            return new ForecastDto.ForecastResponseDto
            {
                ForecastId = f.ForecastId,
                ProductId = f.ProductId,
                ProductName = f.Product?.ProductName ?? "N/A",
                ProductCode = f.Product?.ProductCode ?? "N/A",
                Unit = f.Product?.Unit ?? DefaultUnit,
                ForecastType = f.ForecastType,
                PredictQuantity = f.PredictQuantity,
                CurrentStock = f.CurrentStock,
                SuggestReStock = f.SuggestReStock,
                ForecastDate = f.ForecastDate,
                AvgDailySales = f.AvgDailySales,
                GeneratedAt = f.GeneratedAt
            };
        }
        public async Task<List<Product>> GetQualifiedProductsAsync()
        {
            return await _forecastRepository.GetAllProductsAsync();
        }
    }
}