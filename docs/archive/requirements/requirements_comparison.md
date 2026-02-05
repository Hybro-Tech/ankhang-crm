# 📊 So sánh Yêu cầu: SRS v1.0 vs Yêu cầu Mới (24/01/2026)

> **Mục đích:** Tài liệu so sánh giữa yêu cầu cũ và yêu cầu mới từ khách hàng, phục vụ việc chốt requirement trước khi thiết kế hệ thống.

---

## 1. Role Sale

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới | Trạng thái |
|----------|---------------|-------------|------------|
| **Nguồn khách hàng** | Tổng đài tạo, Sale pick | Tổng đài tạo → Chuyển sang Sale (Smart Routing) | 🔄 Thay đổi |
| **Trạng thái ban đầu** | "Mới" → Sale pick → "Đang tư vấn" | "Tiềm năng" khi nhận từ CSKH | 🔄 Thay đổi |
| **Trạng thái chốt** | "Chốt" (1 loại) | "Chốt Mới" (trong tháng) / "Chốt Cũ" (từ tháng trước) | 🆕 Mới |
| **Trạng thái pending** | Không có | "Tiềm năng" → Qua tháng → "Tiềm năng cũ" | 🆕 Mới |
| **Lịch sử trao đổi** | Có: Nội dung, Loại, Thời điểm, Người trao đổi | Thêm: **Lịch hẹn tiếp theo** | 🆕 Bổ sung |
| **Dashboard** | Chung cho tất cả | **Dashboard riêng cho Sale** với: Danh sách KH, Lịch hẹn (1 tuần tới), Đua top | 🆕 Mới |
| **Danh sách KH** | Chung | Riêng cho Sale, sort ưu tiên KH chưa ai nhận | 🆕 Mới |
| **UI/UX** | Tiêu chuẩn | **Focus 1 màn hình Dashboard**, tối ưu thao tác nhanh | 🆕 Yêu cầu đặc biệt |

---

## 2. Role Tổng đài

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới | Trạng thái |
|----------|---------------|-------------|------------|
| **Dashboard** | Không riêng | **Dashboard riêng cho Tổng đài** | 🆕 Mới |
| **Phương thức liên hệ** | SĐT, Email | Thêm: **Zalo** (QR + Link) | 🆕 Bổ sung |
| **Màn hình tạo Contact** | Form chuẩn | **Tối ưu UI/UX** để nhập nhanh nhất | 🆕 Yêu cầu đặc biệt |
| **Thống kê** | Không có | Màn hình thống kê KH đã tạo + Filter theo ngày tháng | 🆕 Mới |
| **Loại nhu cầu** | Enum cố định trong Contact | **Màn hình CRUD riêng** (Admin quản lý) | 🔄 Thay đổi |

---

## 3. Smart Routing (Phân bổ Contact)

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới | Trạng thái |
|----------|---------------|-------------|------------|
| **Cơ chế** | Pool Pick (ai nhanh được trước) + Cooldown 5 phút | **Smart Routing** theo khung giờ | 🔄 Thay đổi lớn |
| **Giờ hành chính (T2-T6: 8h-17h30)** | — | Random 1 Sale → Chờ 2 phút → Random tiếp | 🆕 Mới |
| **Thứ 7 (8h-11h30)** | — | Random từ **Danh sách đi làm thứ 7** | 🆕 Mới |
| **Ngoài giờ** | — | Gửi cho **tất cả** trong team (Pool pick cũ) | 🆕 Mới |
| **Thời gian chờ** | Cooldown 5 phút | **2 phút** (Admin config được) | 🔄 Thay đổi |
| **Loại nhu cầu → Team** | Không có | Loại nhu cầu A → Team A, Loại B → Team B | 🆕 Mới |

---

## 4. Cấu trúc Team

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới | Trạng thái |
|----------|---------------|-------------|------------|
| **Quan hệ User-Team** | 1 User = 1 Team | 1 User = **Nhiều Team** | 🔄 Thay đổi |
| **Leader** | 1 Team có 1 Leader (tuỳ chọn) | 1 Team có **nhiều Leader**. Mỗi User có 1 Leader trong 1 Team | 🔄 Thay đổi |
| **Danh sách thứ 7** | Không có | **Màn hình CRUD** quản lý nhân viên đi làm thứ 7 | 🆕 Mới |
| **Ngày nghỉ/Lễ** | Không có | **Màn hình quản lý** (mặc định VN, Admin chỉnh sửa) | 🆕 Mới |

---

## 5. Role CSKH

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới | Trạng thái |
|----------|---------------|-------------|------------|
| **"Cướp khách"** | Không có | CSKH request → Leader approve → Chuyển contact | 🆕 Mới (TODO) |

---

## 6. ZNS (Zalo Notification Service)

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới | Trạng thái |
|----------|---------------|-------------|------------|
| **Gửi thủ công** | CSKH gửi cho 1 khách | CSKH gửi cho **1 hoặc nhiều** khách | 🔄 Bổ sung |
| **Gửi tự động** | Không rõ ràng | Theo **rule** (cần trao đổi chi tiết) | 🆕 Mới |
| **Mẫu ZNS** | Không có | **Màn hình CRUD** quản lý mẫu ZNS | 🆕 Mới |

---

## 7. Notification

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới | Trạng thái |
|----------|---------------|-------------|------------|
| **Kênh** | Web Push, Email, Zalo OA, Slack | Web Push + **WebSocket** (ưu tiên) → Slack | 🔄 Rõ ràng hơn |
| **Hiển thị** | Không rõ | Góc phải màn hình Web | ✅ Xác nhận |
| **Thứ tự ưu tiên** | Không có | Web → App (Slack) | 🆕 Mới |
| **Custom rule** | Có (Notification Rules) | Giữ nguyên + bổ sung | ✅ Giữ |

---

## 8. Các mục BỎ khỏi Phase 1

| Hạng mục | SRS v1.0 (Cũ) | Yêu cầu Mới |
|----------|---------------|-------------|
| **Coupon** | Có trong Phase 1 | ❌ **BỎ** - Chuyển sang Phase sau |

---

## 9. Các mục cần làm rõ (TODO)

| # | Hạng mục | Chi tiết |
|---|----------|----------|
| 1 | "Hoàn thành thông tin" theo Role | Tổng đài 5 trường, Sale 15 trường - Cần làm rõ logic |
| 2 | CSKH "Cướp khách" | Điều kiện, quy trình, giới hạn |
| 3 | Smart Routing - Hết người | Nếu không ai nhận thì xử lý thế nào? |
| 4 | ZNS Rules | Danh sách rule tự động gửi ZNS |
| 5 | Nội dung mẫu ZNS | Cần template cụ thể |

---

> **Ghi chú:** Xem chi tiết các câu hỏi cần hỏi khách hàng tại file [customer_qa.md](./customer_qa.md)
