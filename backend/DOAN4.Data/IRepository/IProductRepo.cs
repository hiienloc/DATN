using DOAN4.Models;

namespace DOAN4.IRepository
{
    public interface IProductRepo
    {
        Task<List<Product>> GetAllProductsAsync();
        Task<Product> GetProductByIdAsync(int productId);   
        Task AddProductAsync(Product product);
        Task LockProductAsync(int productId);
        Task UpdateProductAsync(Product product);
        Task<List<string>> GetActivePackageNamesByProductIdAsync(int productId);
    }
}
