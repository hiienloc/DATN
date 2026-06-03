using DOAN4.Dto;
using DOAN4.IRepository;
using DOAN4.IService;

namespace DOAN4.Service
{
    public class ProductService : IProductService
    {
        private readonly IProductRepo _productRepo;

        public ProductService(IProductRepo productRepo)
        {
            _productRepo = productRepo;
        }

        public async Task<List<ProductDto.ProductResponse>> GetAllProductsAsync()
        {
            var products = await _productRepo.GetAllProductsAsync();
            return products.Select(p => new ProductDto.ProductResponse
            {
                ProductId = p.ProductId,
                ProductCode = p.ProductCode,
                ProductName = p.ProductName,
                Unit = p.Unit,
                IsActive = p.IsActive,
                CategoryId = p.CategoryId
            }).ToList();
        }

        public async Task<ProductDto.ProductResponse> GetProductByIdAsync(int productId)
        {
            var product = await _productRepo.GetProductByIdAsync(productId)
                ?? throw new KeyNotFoundException($"Không tìm thấy sản phẩm với ID {productId}");

            return new ProductDto.ProductResponse
            {
                ProductId = product.ProductId,
                ProductCode = product.ProductCode,
                ProductName = product.ProductName,
                Unit = product.Unit,
                IsActive = product.IsActive,
                CategoryId = product.CategoryId
            };
        }

        public async Task AddProductAsync(ProductDto.Create productDto)
        {
            var allProducts = await _productRepo.GetAllProductsAsync();

            // Check trùng ProductCode
            if (allProducts.Any(p => p.ProductCode.Trim().ToLower() == productDto.ProductCode.Trim().ToLower()))
                throw new InvalidOperationException($"Mã sản phẩm '{productDto.ProductCode}' đã tồn tại.");

            // Check trùng ProductName
            if (allProducts.Any(p => p.ProductName.Trim().ToLower() == productDto.ProductName.Trim().ToLower()))
                throw new InvalidOperationException($"Tên sản phẩm '{productDto.ProductName}' đã tồn tại.");

            var product = new Models.Product
            {
                ProductCode = productDto.ProductCode,
                ProductName = productDto.ProductName,
                Unit = productDto.Unit,
                IsActive = productDto.IsActive,
                CategoryId = productDto.CategoryId
            };

            await _productRepo.AddProductAsync(product);
        }

        public async Task UpdateProductAsync(ProductDto.Update productDto)
        {
            var product = await _productRepo.GetProductByIdAsync(productDto.ProductId)
                ?? throw new KeyNotFoundException($"Không tìm thấy sản phẩm với ID {productDto.ProductId}");

            var allProducts = await _productRepo.GetAllProductsAsync();

          
            if (allProducts.Any(p => p.ProductId != productDto.ProductId
                                  && p.ProductCode.Trim().ToLower() == productDto.ProductCode.Trim().ToLower()))
                throw new InvalidOperationException($"Mã sản phẩm '{productDto.ProductCode}' đã tồn tại.");

           
            if (allProducts.Any(p => p.ProductId != productDto.ProductId
                                  && p.ProductName.Trim().ToLower() == productDto.ProductName.Trim().ToLower()))
                throw new InvalidOperationException($"Tên sản phẩm '{productDto.ProductName}' đã tồn tại.");



            product.ProductCode = productDto.ProductCode;
            product.ProductName = productDto.ProductName;
            product.Unit = productDto.Unit;
            product.CategoryId = productDto.CategoryId;
            product.IsActive = productDto.IsActive;

            await _productRepo.UpdateProductAsync(product);
        }

        public async Task LockProductAsync(int productId)
        {
            var product = await _productRepo.GetProductByIdAsync(productId)
                ?? throw new KeyNotFoundException($"Không tìm thấy sản phẩm với ID {productId}");



            await _productRepo.LockProductAsync(productId);
        }
    }
}