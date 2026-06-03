# 🎓 Đồ Án Tốt Nghiệp: Xây dựng website bán nông sản tích hợp AI dự báo nhu cầu tiêu thụ

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
1. Tạo database `FreshFarmDb` trong **SQL Server**.
2. Chạy duy nhất file script `/database/database_setup.sql` để khởi tạo cả cấu trúc bảng và dữ liệu mẫu.

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

---

## 📝 Thông Tin Đồ Án
*   **Đề tài:** Xây dựng website bán nông sản tích hợp AI dự báo nhu cầu tiêu thụ
*   **Sinh viên thực hiện:** Lộc Thị Bích Hiên
