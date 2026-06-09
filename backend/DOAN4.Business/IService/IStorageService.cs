namespace DOAN4.IService
{
    public interface IStorageService
    {
        Task<string> UploadImageAsync(IFormFile file);
    }
}
