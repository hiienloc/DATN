using DOAN4.IService;

namespace DOAN4.Service
{
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
