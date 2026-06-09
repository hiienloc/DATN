using DOAN4.Models;

namespace DOAN4.IRepository
{
    public interface ICartRepo
    {
        Task<Cart?> GetCartByUserIdAsync(int userId);
        Task<CartItem?> GetCartItemAsync(int userId, int packageId);
        Task<CartItem?> GetCartItemByIdAsync(int cartItemId);
        Task AddCartAsync(Cart cart);
        Task AddCartItemAsync(CartItem cartItem);
        Task UpdateCartItemAsync(CartItem cartItem);
        Task RemoveCartItemAsync(CartItem cartItem);
        Task ClearCartAsync(int userId);
        Task SaveChangesAsync();
    }
}
