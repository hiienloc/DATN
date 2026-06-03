using DOAN4.Data;
using DOAN4.IRepository;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;
using System.Diagnostics.Eventing.Reader;

namespace DOAN4.Repository
{
    public class ProductRepo : IProductRepo
    {
        private readonly AppDbContext _context;
        public ProductRepo(AppDbContext context)
        {
            _context = context;
        }
        public async Task AddProductAsync(Product product)
        {
            await _context.Products.AddAsync(product);
            await _context.SaveChangesAsync();
        }

        public async Task LockProductAsync(int productId)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.ProductId == productId);
            if (product == null)
            {
                throw new KeyNotFoundException($"Không tìm thấy sản phẩm với ID {productId}");
            }
            else
            {
                product.IsActive = false;
                await _context.SaveChangesAsync();
            }

        }


        public async Task<List<Product>> GetAllProductsAsync()
        {
            return await _context.Products.ToListAsync();

        }

        public async Task<Product> GetProductByIdAsync(int productId)
        {
            return await _context.Products.FirstOrDefaultAsync(p => p.ProductId == productId);
        }

        public async Task UpdateProductAsync(Product product)
        {
            var entry = _context.Entry(product);
            if (entry.State == EntityState.Detached)
            {
                var tracked = _context.Products.Local.FirstOrDefault(p => p.ProductId == product.ProductId);
                if (tracked != null)
                {
                    _context.Entry(tracked).CurrentValues.SetValues(product);
                }
                else
                {
                    _context.Products.Update(product);
                }
            }
            
            await _context.SaveChangesAsync();
        }

        public async Task<List<string>> GetActivePackageNamesByProductIdAsync(int productId)
        {
            return await _context.PackageItems
                .Where(pi => pi.ProductId == productId
                          && pi.Package.IsActive)
                .Select(pi => pi.Package.PackageName)
                .Distinct()
                .ToListAsync();
        }
    }
}
