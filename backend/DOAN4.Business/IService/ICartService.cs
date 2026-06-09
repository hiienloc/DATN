using DOAN4.Dto;

namespace DOAN4.IService
{
    public interface ICartService
    {
        Task<CartDto.CartResponseDto> GetCartByUserIdAsync(int userId);
        Task AddToCartAsync(int userId, CartDto.AddToCartDto dto);
        Task UpdateCartAsync(int userId, CartDto.UpdateQuantityDto dto);
        Task RemoveFromCartAsync(int cartItemId);
        Task ClearCartAsync(int userId);
        Task<OrderDto.CreateOrderDto> CheckoutAsync(int userId);
    }
}
