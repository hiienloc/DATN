using DOAN4.Data;
using DOAN4.IRepository;
using DOAN4.Models;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Repository
{
    public class CartRepo : ICartRepo
    {
        private readonly AppDbContext _context;

        public CartRepo(AppDbContext context)
        {
            _context = context;
        }
        public async Task AddCartAsync(Cart cart)
        {
            var addedCart = await _context.Carts.Where(c => c.UserId == cart.UserId).FirstOrDefaultAsync();
            if (addedCart == null)
            {
                await _context.Carts.AddAsync(cart);
            }
        }

        public async Task AddCartItemAsync(CartItem cartItem)
        {
            var addCart = await _context.CartItems
        .FirstOrDefaultAsync(ci => ci.CartId == cartItem.CartId
                                && ci.PackageId == cartItem.PackageId);
            if (addCart != null)
            {
                addCart.CartQuantity += cartItem.CartQuantity;
                _context.CartItems.Update(addCart);
            }
            else
            {
                await _context.CartItems.AddAsync(cartItem);
            }
        }

        public async Task ClearCartAsync(int userId)
        {
            var cartItems = await _context.CartItems
                .Where(ci => ci.Cart.UserId == userId)
                .ToListAsync();
            foreach (var cartItem in cartItems)
            {
                _context.CartItems.Remove(cartItem);
            }
        }

        public async Task<Cart?> GetCartByUserIdAsync(int userId)
        {
            return await _context.Carts
         .Include(c => c.CartItems)
             .ThenInclude(ci => ci.Package)
                 .ThenInclude(p => p.PackageItems)
                     .ThenInclude(pi => pi.Product)
                         .ThenInclude(pr => pr.Inventory)
         .FirstOrDefaultAsync(c => c.UserId == userId);

        }

        public async Task<CartItem?> GetCartItemAsync(int userId, int packageId)
        {
            return await _context.CartItems
        .Where(ci => ci.Cart.UserId == userId && ci.PackageId == packageId)
        .FirstOrDefaultAsync();
        }

        public async Task<CartItem?> GetCartItemByIdAsync(int cartItemId)
        {
            var cartItem = await _context.CartItems
                .Where(ci => ci.CartItemId == cartItemId)
                .FirstOrDefaultAsync();
            return cartItem;
        }

        public async Task RemoveCartItemAsync(CartItem cartItem)
        {
            _context.CartItems.Remove(cartItem);
          //  await _context.SaveChangesAsync();
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }

        public async Task UpdateCartItemAsync(CartItem cartItem)
        {
            _context.CartItems.Update(cartItem);
            //await _context.SaveChangesAsync();
        }
    }
}

