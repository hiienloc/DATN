# 🖥️ Fresh Farm Backend API

Dự án API Backend cho đồ án tốt nghiệp: **Xây dựng website bán nông sản tích hợp AI dự báo nhu cầu tiêu thụ**, được thiết kế theo **Kiến trúc 3 lớp (Three-Layer Architecture)**:
1.  **Presentation Layer (Controllers):** Tiếp nhận các yêu cầu HTTP từ client.
2.  **Business Logic Layer (Services):** Xử lý toàn bộ logic nghiệp vụ của dự án.
3.  **Data Access Layer (Repositories & EF Core):** Giao tiếp trực tiếp và truy vấn CSDL SQL Server.

## Công Nghệ
*   ASP.NET Core 8.0 Web API
*   Entity Framework Core (Repository & Unit of Work patterns)
*   Microsoft SQL Server
*   Thanh toán qua **VNPay & COD**

## Cấu Hình & Khởi Chạy
1. Cấu hình chuỗi kết nối Database tại file [appsettings.json](file:///c:/Users/locth/source/repos/DOANTN/backend/DOAN4/appsettings.json).
2. Chạy lệnh:
   ```bash
   dotnet run
   ```
