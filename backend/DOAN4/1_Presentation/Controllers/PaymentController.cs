using DOAN4.Dto;
using DOAN4.IService;
using DOAN4.Models;
using DOAN4.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace DOAN4.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        private readonly IOrderService _orderService;
        private readonly IVnpayService _vnPayService;
        private readonly IConfiguration _configuration;

        public PaymentController(
            IPaymentService paymentService,
            IOrderService orderService,
            IVnpayService vnPayService,
            IConfiguration configuration)
        {
            _paymentService = paymentService;
            _orderService = orderService;
            _vnPayService = vnPayService;
            _configuration = configuration;
        }

        [Authorize(Roles = "Customer")]
        [HttpPost("create-payment")]
        public async Task<IActionResult> CreatePayment([FromBody] OrderDto.CreateOrderDto dto)
        {
            try
            {
                // Force user ownership on order creation
                var userId = GetUserIdFromToken();
                dto.UserId = userId;

                var order = await _orderService.CreateOrderAsync(dto);

                if (string.Equals(dto.PaymentMethod, "VNPay", StringComparison.OrdinalIgnoreCase))
                {
                    string vnpayUrl = _vnPayService.GenerateVnPayUrl(
                        HttpContext,
                        order.OrderId,
                        order.TotalAmount,
                        $"Thanh toan don hang {order.OrderCode}"
                    );
                    return Ok(new { url = vnpayUrl, orderId = order.OrderId });
                }

                await _paymentService.CreateCodPaymentAsync(order.OrderId, order.TotalAmount);
                return Ok(new { success = true, orderId = order.OrderId, message = "Đặt hàng thành công. Thanh toán khi nhận hàng." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("cod-confirm/{orderId}")]
        public async Task<IActionResult> ConfirmCodPayment(int orderId)
        {
            try
            {
                await _paymentService.UpdateCodPaidAsync(orderId);
                return Ok(new { success = true, message = "Xác nhận thanh toán COD thành công" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

      
        [HttpGet("PaymentCallback")]
        public async Task<IActionResult> PaymentCallBack()
        {
            try
            {
                var result = await _paymentService.HandleVnpayCallbackAsync(Request.Query);

                if (!result.IsSuccess)
                    return Redirect($"/payment-failed?orderId={result.OrderId}&code={result.ResponseCode}");

                return Redirect($"/payment-success?orderId={result.OrderId}");
            }
            catch (Exception ex)
            {
                return Redirect($"/payment-failed?error={Uri.EscapeDataString(ex.Message)}");
            }
        }

        [Authorize]
        [HttpGet("payment-status/{orderId}")]
        public async Task<IActionResult> GetPaymentStatus(int orderId)
        {
            try
            {
                var payment = await _paymentService.GetPaymentByOrderIdAsync(orderId);
                if (payment == null)
                    return NotFound(new { message = "Payment not found" });

                // Check ownership to prevent IDOR
                var order = await _orderService.GetOrderByIdAsync(orderId);
                if (order == null)
                    return NotFound(new { message = "Order not found" });

                var loggedInUserId = GetUserIdFromToken();
                if (User.IsInRole("Customer") && order.UserId != loggedInUserId)
                {
                    return Forbid();
                }
               
                return Ok(new OrderDto.PaymentResponseDto
                {
                    PaymentId = payment.PaymentId,
                    OrderId = payment.OrderId,
                    PaymentMethod = payment.PaymentMethod,
                    Amount = payment.Amount,
                    PaymentStatus = payment.PaymentStatus,
                    CreatedAt = payment.CreatedAt,
                    UpdatedAt = payment.UpdatedAt,
                    Transactions = payment.Transactions?.Select(t => new OrderDto.TransactionDto
                    {
                        TransactionId = t.TransactionId,
                        TransactionNo = t.TransactionNo,
                        BankCode = t.BankCode,
                        ResponseCode = t.ResponseCode,
                        Status = t.Status,
                        TransactionDate = t.TransactionDate
                    }).ToList() ?? new List<OrderDto.TransactionDto>()
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        private int GetUserIdFromToken()
        {
            var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                throw new UnauthorizedAccessException("Không tìm thấy thông tin người dùng trong token.");
            return int.Parse(userIdClaim.Value);
        }
    }
}