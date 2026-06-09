using DOAN4.IService;

namespace DOAN4.Service
{
    /// <summary>
    /// Lớp StorageService quản lý hoạt động lưu trữ tập tin hình ảnh sản phẩm/combo lên Web Server:
    /// - Nhận file hình ảnh tải lên từ client (IFormFile).
    /// - Tạo tên file duy nhất bằng Guid để tránh ghi đè và lưu vào thư mục 'Uploads' trên server.
    /// - Trả về đường dẫn ảnh tương đối dạng '/images/filename' để lưu vào cơ sở dữ liệu.
    /// </summary>
    public class StorageService : IStorageService
    {
        private readonly IWebHostEnvironment _env;

        public StorageService(IWebHostEnvironment env)
        {
            _env = env;
        }

        public async Task<string> UploadImageAsync(IFormFile file)
        {
            // tạo tên file unique tránh trùng
            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var folder = Path.Combine(_env.ContentRootPath, "Uploads");

            // tạo folder nếu chưa có
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // trả về đường dẫn lưu vào DB
            return $"/images/{fileName}";
        }
    }
}
