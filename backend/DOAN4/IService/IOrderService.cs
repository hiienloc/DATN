using DOAN4.Dto;

namespace DOAN4.IService
{
    public interface IOrderService
    {
       
            Task<OrderDto.OrderResponseDto> CreateOrderAsync(OrderDto.CreateOrderDto orderDto);
            Task<OrderDto.OrderResponseDto> GetOrderByIdAsync(int id);
            Task<List<OrderDto.OrderResponseDto>> GetOrdersAsync();
            Task<List<OrderDto.OrderResponseDto>> GetOrdersByUserIdAsync(int userId);
            Task<OrderDto.OrderResponseDto> UpdateOrderStatusAsync(int id, string status);
            Task<OrderDto.OrderResponseDto> CancelOrderAsync(int id);
        

    }
}
