# Yêu Cầu Hệ Thống Dashboard Theo Role

> **Version:** 1.0  
> **Ngày tạo:** 2026-01-28  
> **Trạng thái:** Đang triển khai

---

## Tổng Quan

Hệ thống CRM cần xây dựng Dashboard riêng cho 4 roles chính:
- **Tổng Đài** - Nhập liệu khách hàng
- **Sale** - Bán hàng, chốt deal
- **CSKH** - Chăm sóc khách hàng
- **Admin** - Quản trị hệ thống

---

## Chi Tiết Yêu Cầu

### 1. Tổng Đài (Call Center)

| Chức năng | Mô tả | Trạng thái |
|-----------|-------|------------|
| Màn hình làm việc | Form nhập nhanh + lịch sử vừa nhập | ✅ Đã có |
| Time Filter | Lọc theo hôm nay/tuần/tháng | 🔲 Cần làm |
| Export Excel | Xuất danh sách contact đã tạo | 🔲 Cần làm |
| Màn hình thống kê | KPI, trend chart, progress bar | 🔲 Cần làm |
| Danh sách contact | Contact mình tạo (chưa assign) | 🔲 Cần làm |

### 2. Sale

| Chức năng | Mô tả | Trạng thái |
|-----------|-------|------------|
| Màn hình làm việc | KPI cards, charts, lịch hẹn | ✅ Đã có |
| Danh sách cần xử lý | Contacts được assign | ✅ Đã có |
| Pipeline Kanban | Drag-drop contacts giữa stages | 🔲 Cần làm |
| Màn hình thống kê | Conversion funnel, performance | 🔲 Cần làm |

### 3. Admin

| Chức năng | Mô tả | Trạng thái |
|-----------|-------|------------|
| Dashboard tổng quan | KPI toàn hệ thống | ✅ Đã làm |
| Team comparison | So sánh hiệu quả teams | ✅ Đã làm |
| Sales comparison | So sánh hiệu quả sales | ✅ Đã làm |
| Top performers | Nhân viên xuất sắc | ✅ Đã làm |
| Export report | Xuất báo cáo tổng hợp | 🔲 Cần làm |
| Full CRUD access | Quản lý toàn hệ thống | ✅ Đã có |

### 4. CSKH (Customer Service)

| Chức năng | Mô tả | Trạng thái |
|-----------|-------|------------|
| Màn hình làm việc | Queue list khách cần chăm sóc | 🔲 Cần làm |
| KPI Cards | Cases hôm nay, pending, response time | 🔲 Cần làm |
| ZNS Placeholder | UI gửi tin nhắn (logic sau) | 🔲 Cần làm |
| Màn hình thống kê | Charts phân tích | 🔲 Cần làm |

### 5. Chung (All Roles)

| Chức năng | Mô tả | Trạng thái |
|-----------|-------|------------|
| Permission Sidebar | Menu hiển thị theo quyền | ✅ Đã làm |
| Real-time notifications | Thông báo khi có contact mới | 🔲 Phase 2 |

---

## Quyết Định Kỹ Thuật

### Sidebar Permission
- **Phương án:** Sử dụng CanCanCan abilities hiện có
- **Lý do:** Đã có hệ thống RBAC hoàn chỉnh, không cần thêm field `visible_menus`
- **Implementation:** `sidebar_section` helper + `can_access?` check

### Dashboard Routing
- **Phương án:** Dùng `dashboard_type` trên Role model
- **Implementation:** `current_user.primary_dashboard_type` trong controller

---

## Legend

- ✅ Đã hoàn thành
- 🔲 Cần làm
- ⏸️ Tạm hoãn
