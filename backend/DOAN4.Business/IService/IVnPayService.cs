namespace DOAN4.IService
{
    public interface IVnpayService
    {
        string GenerateVnPayUrl(HttpContext context, int orderId, decimal amount, string orderInfo);

    
        Task<(bool isValid, Dictionary<string, string> data)> ValidateVnPayResponse(IQueryCollection query);
    }
}
