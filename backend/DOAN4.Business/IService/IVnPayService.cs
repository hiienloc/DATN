namespace DOAN4.IService
{
    public interface IVnpayService
    {
        string GenerateVnPayUrl(HttpContext context, long txnRefId, decimal amount, string orderInfo);

    
        Task<(bool isValid, Dictionary<string, string> data)> ValidateVnPayResponse(IQueryCollection query);
    }
}
