# � Kickoff Meeting Agenda & Questions

> **Date**: 24/01/2026 (Dự kiến)
> **Goal**: Thống nhất Specs, Demo Design, và chốt các điểm chưa rõ để team Dev chạy hết công suất.

---

## 1. � Phần 1: Review tài liệu yêu cầu (SRS v1.1)

> **Mục tiêu**: Show cho khách thấy mình đã hiểu nghiệp vụ và đã update document theo feedback mới nhất.

### 1.1 Các điểm cập nhật chính (v1.1)
*   **Loại nhu cầu (Service Types)**: Đã chuyển thành **Module quản lý động**.
    *   Admin có thể thêm/sửa/xóa các loại nhu cầu (VD: Thành lập cty, Kế toán, Giấy phép con...).
    *   Không còn fix cứng trong code.
*   **Luồng trạng thái (Contact Status)**:
    *   Đã gộp *"Đã nhận"* và *"Tiềm năng"* -> **"Đang tư vấn"**.
    *   Giúp Sale giảm bớt thao tác: Pick xong là tính đang tư vấn luôn.

### 1.2 Demo Logic quan trọng: Pick Contact
*   Show lại sơ đồ luồng Pick contact (First-come First-served).
*   **CONFIRMED**:
    *   Cơ chế **Dynamic Rules**: Admin cấu hình rule cho từng loại contact.
    *   Ví dụ:
        *   *Kế toán*: Max 2 số/ngày.
        *   *Thành lập Cty*: Max 5 số/ngày.
        *   *Cooldown*: Tối thiểu 5 phút giữa 2 lần pick.
    *   **Admin Override**: Admin có quyền "Lấy lại" liên hệ từ Sale này để gán cho Sale khác (Re-assign).
    *   **Domain**: `ankhang.vn` (Confirmed).
    *   **Hạ tầng**: VPS DigitalOcean (Confirmed).

---

## 2. 🗺️ Phần 2: Timeline & Demo Mockup

> **Mục tiêu**: Cho khách thấy hình hài sản phẩm và lộ trình về đích.

### 2.1 Project Plan (Master Plan)
*   **Ngày Start**: 19/01/2026.
*   **Lịch nghỉ Tết**: 10/02 - 23/02 (2 tuần).
*   **Các mốc quan trọng (Milestones)**:
    *   *Trước Tết (09/02)*: Xong khung sườn (Login, Phân quyền, CRUD cơ bản Team/User).
    *   *Sprint 3 (09/03)*: Xong Core Features (Contacts, Pick Rules phức tạp, Deals).
    *   *Sprint 4 (23/03)*: Xong Full Features (Noti, Dashboard, Reports).
    *   *Deadline (31/03)*: Bàn giao & Deploy.

### 2.2 Demo Mockup (UI/UX)
*   Mở trình duyệt show các màn hình chính:
    1.  **Dashboard**: Tổng quan KPI.
    2.  **Contact List**: Bộ lọc, tìm kiếm.
    3.  **Roles & Permissions**: Ma trận phân quyền.
    4.  **Pick Contact**: Mô phỏng nút nhận khách.

---

## 3. ❓ Phần 3: Q&A - Làm rõ các điểm chưa Clear

> **Mục tiêu**: Lấy thông tin đầu vào cho các tính năng sắp tới.

### A. Hạ tầng & Triển khai (Infrastructure)
1.  **Zalo OA**: Tài khoản Zalo OA đã xác thực chưa? (Cần xác thực mới gửi ZNS được).

### B. Nghiệp vụ chi tiết (Business Logic)
2.  **Dữ liệu ban đầu (Seeding)**:
    *   Cần anh cung cấp danh sách các "Loại nhu cầu" thực tế đang dùng để em input sẵn vào hệ thống.
    *   Danh sách các Team/Phòng ban hiện tại.
3.  **Mẫu tin Zalo (ZNS Templates)**:
    *   Đã có nội dung mẫu chưa? (Cần đăng ký với Zalo xét duyệt mất 3-5 ngày).
    *   Tần suất gửi tin chăm sóc tự động? (Ví dụ: Sau khi Fail thì bao lâu nhắn lại? Nhắn mấy lần?).
4.  **Quản lý công nợ (Partial Payment)**:
    *   Hiện tại SRS chỉ có trạng thái (Chưa trả / Trả 1 phần / Đã trả).
    *   Hệ thống có cần lưu chi tiết **Lịch sử thanh toán** (Ngày A trả 3tr, Ngày B trả 5tr...) không? Hay chỉ cần Sale tự note vào ghi chú?

---

## 4. ✅ Tổng kết
*   Chốt lại các thay đổi trong SRS v1.1.
*   Khách hàng cung cấp các thông tin còn thiếu (Domain, Zalo info, List dịch vụ).
