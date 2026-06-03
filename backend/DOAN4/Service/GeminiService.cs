using DOAN4.IService;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace DOAN4.Service
{
   
    internal sealed record GeminiPrediction(
        decimal PredictedQuantity,
        int ForecastDays,
        decimal AvgPerDay);

    public class GeminiService : IGeminiService
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<GeminiService> _logger;

        private const string GeminiBaseUrl =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
        private const string GeminiClientName = "GeminiClient";
        private const string ApiKeyHeader = "x-goog-api-key";
        private const double InconsistencyThreshold = 0.20; // 20% chênh lệch cho phép

        public GeminiService(
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            ILogger<GeminiService> logger)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _logger = logger;
        }

        // Dự báo chỉ từ lịch sử tiêu thụ (dùng khi không có dữ liệu xuất kho)
        public async Task<decimal> ForecastQuantityAsync(
            string productName,
            List<decimal> history,
            string unit = "đơn vị",
            int forecastDays = 7)
        {
            if (history == null || !history.Any())
            {
                _logger.LogWarning(
                    "Không có dữ liệu lịch sử tiêu thụ cho '{ProductName}'. Bỏ qua AI.",
                    productName);
                return 0;
            }

            var prompt = BuildSingleSourcePrompt(productName, history, unit, forecastDays);
            var prediction = await CallGeminiApiAsync(prompt, productName, forecastDays);
            return prediction?.PredictedQuantity ?? 0;
        }

        // Dự báo kết hợp từ lịch sử đơn hàng hoàn thành + xuất kho thực tế
        public async Task<decimal> ForecastQuantityWithWarehouseAsync(
            string productName,
            List<decimal> salesHistory,
            List<decimal> exportHistory,
            string unit = "đơn vị",
            int forecastDays = 7)
        {
            var hasSales = salesHistory != null && salesHistory.Any();
            var hasExport = exportHistory != null && exportHistory.Any();

            if (!hasSales && !hasExport)
            {
                _logger.LogWarning(
                    "Không có dữ liệu lịch sử bán hàng lẫn xuất kho cho '{ProductName}'. Bỏ qua AI.",
                    productName);
                return 0;
            }

            var prompt = BuildDualSourcePrompt(
                productName,
                salesHistory ?? new List<decimal>(),
                exportHistory ?? new List<decimal>(),
                unit,
                forecastDays);

            var prediction = await CallGeminiApiAsync(prompt, productName, forecastDays);
            return prediction?.PredictedQuantity ?? 0;
        }

       

        private static string BuildSingleSourcePrompt(
            string productName,
            List<decimal> history,
            string unit,
            int forecastDays)
        {
            var today = DateTime.Today;
            // Gắn ngày vào từng data point để AI nhận diện được chu kỳ tuần/tháng
            var dataPoints = history
                .Select((qty, i) => $"{today.AddDays(-history.Count + i + 1):yyyy-MM-dd}:{qty}{unit}")
                .ToList();

            return
                $"Bạn là chuyên gia phân tích chuỗi cung ứng nông sản.\n" +
                $"Sản phẩm: '{productName}' (đơn vị: {unit}).\n\n" +
                $"Lịch sử tiêu thụ thực tế:\n[{string.Join(", ", dataPoints)}]\n\n" +
                $"YÊU CẦU:\n" +
                $"1. Phân tích xu hướng, chu kỳ tuần, biến động mùa vụ từ dữ liệu trên.\n" +
                $"2. Dự báo TỔNG nhu cầu tiêu thụ cho đúng {forecastDays} ngày tiếp theo.\n" +
                $"3. Nếu dữ liệu không đủ rõ ràng, áp dụng Moving Average.\n" +
                $"4. Chỉ trả về JSON theo đúng format sau, không kèm markdown hay giải thích:\n\n" +
                $"{{\n" +
                $"  \"forecastDays\": {forecastDays},\n" +
                $"  \"predictedQuantity\": <tổng {forecastDays} ngày, kiểu double>,\n" +
                $"  \"avgPerDay\": <trung bình mỗi ngày, kiểu double>\n" +
                $"}}";
        }

        private static string BuildDualSourcePrompt(
            string productName,
            List<decimal> salesHistory,
            List<decimal> exportHistory,
            string unit,
            int forecastDays)
        {
            var today = DateTime.Today;

            var salesPoints = salesHistory.Any()
                ? salesHistory
                    .Select((qty, i) => $"{today.AddDays(-salesHistory.Count + i + 1):yyyy-MM-dd}:{qty}{unit}")
                    .ToList()
                : new List<string> { "Không có dữ liệu" };

            var exportPoints = exportHistory.Any()
                ? exportHistory
                    .Select((qty, i) => $"{today.AddDays(-exportHistory.Count + i + 1):yyyy-MM-dd}:{qty}{unit}")
                    .ToList()
                : new List<string> { "Không có dữ liệu" };

            return
                $"Bạn là chuyên gia phân tích chuỗi cung ứng nông sản.\n" +
                $"Sản phẩm: '{productName}' (đơn vị: {unit}).\n\n" +
                $"[Nguồn 1] Lịch sử đơn hàng hoàn thành (phản ánh nhu cầu thực của khách):\n" +
                $"[{string.Join(", ", salesPoints)}]\n\n" +
                $"[Nguồn 2] Lịch sử xuất kho thực tế (bao gồm hao hụt, combo, nội bộ):\n" +
                $"[{string.Join(", ", exportPoints)}]\n\n" +
                $"YÊU CẦU:\n" +
                $"1. Đối chiếu cả 2 nguồn: Nguồn 1 phản ánh nhu cầu khách hàng, Nguồn 2 phản ánh lượng hàng thực tế xuất đi.\n" +
                $"2. Phân tích xu hướng, chu kỳ tuần, biến động mùa vụ từ cả 2 nguồn.\n" +
                $"3. Dự báo TỔNG nhu cầu xuất kho cho đúng {forecastDays} ngày tiếp theo.\n" +
                $"4. Nếu dữ liệu không đủ rõ ràng, áp dụng Moving Average trên cả 2 nguồn.\n" +
                $"5. Chỉ trả về JSON theo đúng format sau, không kèm markdown hay giải thích:\n\n" +
                $"{{\n" +
                $"  \"forecastDays\": {forecastDays},\n" +
                $"  \"predictedQuantity\": <tổng {forecastDays} ngày, kiểu double>,\n" +
                $"  \"avgPerDay\": <trung bình mỗi ngày, kiểu double>\n" +
                $"}}";
        }

      

        private async Task<GeminiPrediction?> CallGeminiApiAsync(
            string prompt,
            string productName,
            int expectedForecastDays)
        {
            var apiKey = _configuration["Gemini:ApiKey"];

            if (string.IsNullOrWhiteSpace(apiKey) || apiKey.Contains("YOUR_GEMINI_API_KEY_HERE"))
            {
                _logger.LogWarning("Gemini API key chưa được cấu hình.");
                return null;
            }

            try
            {
                var client = _httpClientFactory.CreateClient(GeminiClientName);

                // API key trong header thay vì URL — tránh lộ key trong access log
                client.DefaultRequestHeaders.Remove(ApiKeyHeader);
                client.DefaultRequestHeaders.Add(ApiKeyHeader, apiKey);

                var requestBody = new
                {
                    contents = new[]
                    {
                        new
                        {
                            role = "user",
                            parts = new[] { new { text = prompt } }
                        }
                    },
                    generationConfig = new
                    {
                        responseMimeType = "application/json",
                        temperature = 0.15  // Gần deterministic — phù hợp bài toán dự báo số liệu
                    }
                };

                var jsonPayload = JsonSerializer.Serialize(requestBody);
                using var content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");
                using var response = await client.PostAsync(GeminiBaseUrl, content);

                if (!response.IsSuccessStatusCode)
                {
                    var errorBody = await response.Content.ReadAsStringAsync();
                    _logger.LogError(
                        "Gemini API lỗi {StatusCode} cho '{ProductName}': {Error}",
                        response.StatusCode, productName, errorBody);
                    return null;
                }

                var responseJson = await response.Content.ReadAsStringAsync();
                return ParseGeminiResponse(responseJson, productName, expectedForecastDays);
            }
            catch (TaskCanceledException ex) when (!ex.CancellationToken.IsCancellationRequested)
            {
                _logger.LogError(
                    "Gemini API timeout khi xử lý '{ProductName}'.", productName);
            }
            catch (TaskCanceledException)
            {
                _logger.LogWarning(
                    "Request Gemini API bị huỷ từ bên ngoài cho '{ProductName}'.", productName);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex,
                    "Lỗi parse JSON từ Gemini cho '{ProductName}'.", productName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Lỗi không xác định khi gọi Gemini cho '{ProductName}'.", productName);
            }

            return null;
        }

        

        private GeminiPrediction? ParseGeminiResponse(
            string responseJson,
            string productName,
            int expectedForecastDays)
        {
            using var doc = JsonDocument.Parse(responseJson);

            // Lấy text từ candidates[0].content.parts[0].text
            var candidates = doc.RootElement.GetProperty("candidates");
            if (candidates.ValueKind != JsonValueKind.Array || candidates.GetArrayLength() == 0)
            {
                _logger.LogWarning("Gemini không trả về candidates cho '{ProductName}'.", productName);
                return null;
            }

            var textNode = candidates[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString();

            if (string.IsNullOrWhiteSpace(textNode))
            {
                _logger.LogWarning("Gemini trả về text rỗng cho '{ProductName}'.", productName);
                return null;
            }

            // Làm sạch markdown nếu AI trả về dù đã dặn không cần
            var cleanJson = textNode.Trim();
            if (cleanJson.StartsWith("```"))
                cleanJson = cleanJson.Replace("```json", "").Replace("```", "").Trim();

            using var resultDoc = JsonDocument.Parse(cleanJson);
            var root = resultDoc.RootElement;

            // Parse predictedQuantity (bắt buộc)
            if (!root.TryGetProperty("predictedQuantity", out var predProp) ||
                !predProp.TryGetDecimal(out var predictedQty))
            {
                _logger.LogWarning(
                    "Không parse được 'predictedQuantity' từ Gemini cho '{ProductName}'. JSON: {Json}",
                    productName, cleanJson);
                return null;
            }

            if (predictedQty < 0)
            {
                _logger.LogWarning(
                    "Gemini trả về giá trị âm ({Value}) cho '{ProductName}'. Bỏ qua.",
                    predictedQty, productName);
                return null;
            }

            root.TryGetProperty("avgPerDay", out var avgProp);
            avgProp.TryGetDecimal(out var avgPerDay);

            if (root.TryGetProperty("forecastDays", out var daysProp) &&
                daysProp.TryGetInt32(out var returnedDays) &&
                returnedDays != expectedForecastDays)
            {
                _logger.LogWarning(
                    "AI trả về forecastDays={Returned} nhưng yêu cầu={Expected} cho '{ProductName}'. Bỏ qua kết quả.",
                    returnedDays, expectedForecastDays, productName);
                return null;
            }

           
            if (avgPerDay > 0)
            {
                var expected = avgPerDay * expectedForecastDays;
                var diff = Math.Abs((double)(expected - predictedQty)) / Math.Max((double)expected, 1);
                if (diff > InconsistencyThreshold)
                {
                    _logger.LogWarning(
                        "Kết quả Gemini không nhất quán cho '{ProductName}': " +
                        "avgPerDay={Avg} × {Days} = {Expected} nhưng predictedQuantity={Actual} (chênh {Diff:P0}). " +
                        "Vẫn dùng predictedQuantity.",
                        productName, avgPerDay, expectedForecastDays, expected, predictedQty, diff);
                  
                }
            }

            _logger.LogInformation(
                "[Gemini] Dự báo '{ProductName}': {Value} trong {Days} ngày (avg/ngày: {Avg}).",
                productName, predictedQty, expectedForecastDays, avgPerDay);

            return new GeminiPrediction(predictedQty, expectedForecastDays, avgPerDay);
        }
    }
}