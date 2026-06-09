using DOAN4.Dto;

namespace DOAN4.IService
{
    public interface IProductService
    {
        Task<List<ProductDto.ProductResponse>> GetAllProductsAsync();
        Task<ProductDto.ProductResponse> GetProductByIdAsync(int productId);
        Task AddProductAsync(ProductDto.Create productDto);
        Task LockProductAsync(int productId);
        Task UpdateProductAsync(ProductDto.Update productDto);
    }
}
