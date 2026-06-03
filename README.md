# Website bán nông sản tích hợp AI dự báo nhu cầu tiêu thụ

Hệ thống e-commerce bán nông sản sạch theo combo, tích hợp thanh toán qua **cổng VNPay & COD**, cùng tính năng dự báo lượng bán và đề xuất nhập kho thông minh sử dụng trí tuệ nhân tạo (AI).

🔗 **Link Demo Website (Hosting):** [http://freshfarm.somee.com](http://freshfarm.somee.com)

---

## 📁 Cấu Trúc Dự Án
*   `/database`: Script khởi tạo cơ sở dữ liệu **SQL Server**.
*   `/backend`: API viết bằng **ASP.NET Core 8.0** theo **kiến trúc 3 lớp (Three-Layer)**.
*   `/frontend`: Giao diện viết bằng **Vue.js** (Vite).

---

## 🚀 Khởi Chạy Nhanh

### 1. Cơ Sở Dữ Liệu
1. Tạo database trống trong **SQL Server**.
2. Chạy tệp tin script `/database/database_setup.sql` để khởi tạo cấu trúc bảng.

### 2. Chạy Backend (API)
1. Cấu hình chuỗi kết nối SQL Server trong `/backend/DOAN4/appsettings.json`.
2. Mở terminal tại `/backend/DOAN4` và chạy lệnh:
   ```bash
   dotnet run
   ```

### 3. Chạy Frontend (Client)
1. Mở terminal tại `/frontend` và chạy lệnh:
   ```bash
   npm install
   npm run dev
   ```
