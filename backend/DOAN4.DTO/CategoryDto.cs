using System.ComponentModel.DataAnnotations;

namespace DOAN4.Dto
{
    public class CategoryDto
    {
        public class CreateCategoryDto
        {
            [Required(ErrorMessage = "Bắt buộc nhập tên danh mục.")]
            public string CategoryName { get; set; }
            public bool IsActive { get; set; }
        }
        public class UpdateCategoryDto
        {
            public int CategoryId { get; set; }
                [Required(ErrorMessage = "Bắt buộc nhập tên danh mục.")]
            public string CategoryName { get; set; }
            //public string Description { get; set; }
            public bool IsActive { get; set; }
        }
         public class CategoryResponseDto
        {
            public int CategoryId { get; set; }
            public string CategoryName { get; set; }
            public bool IsActive { get; set; }
        }
    }
}
