using System.ComponentModel.DataAnnotations;

namespace DOAN4.Dto
{
    public class InventoryDto
    {
        // =========================================
        // RESPONSE INVENTORY
        // =========================================
        public class InventoryResponseDto
        {
            public int Id { get; set; }

            public int ProductId { get; set; }

            public string ProductName { get; set; } = string.Empty;

            public string ProductCode { get; set; } = string.Empty;

            public string Unit { get; set; } = string.Empty;

            public decimal QuantityInStock { get; set; }

            public decimal MinStockLevel { get; set; }

            public DateTime LastUpdated { get; set; }
        }

       // Nhập tồn kho
        public class ImportInventoryDto
        {
            [Range(1, int.MaxValue, ErrorMessage = "ProductId không hợp lệ.")]
            public int ProductId { get; set; }

            [Required(ErrorMessage = "Bắt buộc nhập số lượng.")]
            [Range(0.001, double.MaxValue, ErrorMessage = "Số lượng nhập kho phải lớn hơn 0.")]
            public decimal Quantity { get; set; }

            [Range(0, double.MaxValue, ErrorMessage = "Mức tồn kho tối thiểu không được âm.")]
            public decimal MinStockLevel { get; set; }

            [Required(ErrorMessage = "Bắt buộc nhập ghi chú.")]
            public string Note { get; set; } = string.Empty;
        }

        // =========================================
        // UPDATE INVENTORY
        // =========================================
        public class UpdateInventoryDto
        {
            public decimal QuantityChange { get; set; }

            [Range(0, double.MaxValue, ErrorMessage = "Mức tồn kho tối thiểu không được âm.")]
            public decimal? MinStockLevel { get; set; }

            [Required(ErrorMessage = "Bắt buộc nhập ghi chú.")]
            public string Note { get; set; } = string.Empty;
        }

        
        public class InventoryTransactionDto
        {
            public int TransactionId { get; set; }

            public int InventoryId { get; set; }

            public int ProductId { get; set; }

            public string ProductName { get; set; } = string.Empty;

            public int? PackageId { get; set; }

            public decimal QuantityChange { get; set; }

            // IMPORT / EXPORT / UPDATE
            public string TransactionType { get; set; } = string.Empty;

            public string Note { get; set; } = string.Empty;

            public DateTime TransactionDate { get; set; }
        }
    }
}