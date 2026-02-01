# TASK-052: Re-assign / Unassign Contact - Spec

> **Sprint:** 3 | **Priority:** High | **Tạo:** 31/01/2026

---

## 🎯 Mục tiêu

Cho phép Admin:
- **Re-assign:** Chuyển Contact từ Sale A → Sale B
- **Unassign:** Gỡ Contact khỏi Sale A → về pool

Cả 2 hành động cần được **Team Lead (Manager)** phê duyệt.

---

## 🔄 FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ADMIN TẠO YÊU CẦU                                  │
│                                                                              │
│  ┌──────────────┐                                                           │
│  │   Admin      │ ──► Chọn Contact ──► [Chọn Sale B hoặc bỏ trống] ──► Lý do│
│  └──────────────┘                                                           │
│                                                                              │
│  📌 Nếu chọn Sale B  →  RE-ASSIGN (chuyển cho người mới)                    │
│  📌 Nếu bỏ trống     →  UN-ASSIGN (gỡ khỏi Sale A, đưa về pool)             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         HỆ THỐNG GỬI THÔNG BÁO                               │
│                                                                              │
│    📧 Lead (Manager)          📧 Sale A (Owner hiện tại)                    │
│    "Có yêu cầu cần duyệt"     "Contact đang chờ duyệt chuyển"               │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
        ┌───────────────────┐           ┌───────────────────┐
        │   ✅ DUYỆT         │           │   ❌ TỪ CHỐI       │
        │   (Lead)           │           │   (Lead)           │
        └───────────────────┘           └───────────────────┘
                │                               │
                ▼                               ▼
┌────────────────────────────┐      ┌────────────────────────────┐
│ RE-ASSIGN (có Sale B):     │      │ Yêu cầu bị hủy              │
│  → Contact chuyển Sale B   │      │                             │
│  → 📧 Sale B: "Nhận KH"    │      │ 📧 Admin: "Từ chối + Lý do" │
│                            │      │                             │
│ UN-ASSIGN (không có Sale B):│      │                             │
│  → Contact về pool (new)   │      │                             │
│  → ❓ Smart Routing?       │      │                             │
└────────────────────────────┘      └────────────────────────────┘
```

---

## ✅ SPEC ĐÃ CHỐT

| Spec | Quyết định |
|------|------------|
| Ai approve? | **Manager của Team** mà Sale A thuộc |
| UI entry | **Cả 2**: Danh sách `/admin/contacts` + Chi tiết Contact |
| Lịch sử chăm sóc | **Giữ lại** tất cả Interactions khi Unassign |
| Notifications | created→Lead+SaleA, approved→Admin+SaleA+SaleB, rejected→Admin |

---

## ⏳ CHỜ KHÁCH TRẢ LỜI

| # | Câu hỏi | Trạng thái |
|---|--------|-----------|
| 5.1 | Khi Unassign, Contact status như thế nào? (A: về new_contact + Smart Routing, B: giữ status) | ⏳ |
| 5.3 | Contact Unassign được ai pick? (tất cả Sale hay chỉ Team cũ?) | ⏳ |

---

## 🖥️ UI MOCKUPS

### 1. Admin - Danh sách Khách hàng (`/admin/contacts`)

**Mô tả:**
- Table hiển thị tất cả Contacts trong hệ thống
- Filters: Team, Status, Sales Owner, Search
- Mỗi row có Actions dropdown:
  - 👁️ Xem chi tiết
  - ✏️ Chỉnh sửa
  - 🔄 **Chuyển người khác**
  - ❌ **Gỡ phân công**

---

### 2. Modal - Chuyển / Gỡ phân công

**Mô tả:**
- Toggle chọn loại: "Chuyển cho người khác" / "Gỡ phân công"
- Contact info card hiển thị mã, tên, người đang phụ trách
- Dropdown chọn Sale B mới (ẩn khi chọn Gỡ)
- Textarea nhập lý do (bắt buộc)
- Alert: "Yêu cầu sẽ được gửi đến Lead (Tên Lead) để duyệt"
- Nút: Hủy | Gửi yêu cầu

---

### 3. Lead - Danh sách yêu cầu chờ duyệt (`/teams/reassign_requests`)

**Mô tả:**
- Tabs: Tất cả | Chờ duyệt (badge count) | Đã xử lý
- Card layout cho mỗi request:
  - Mã request + thời gian
  - Badge loại: Chuyển KH (cam) | Gỡ KH (đỏ)
  - Contact info: Mã + Tên
  - Transfer info: Sale A → Sale B (hoặc Pool)
  - Lý do yêu cầu
  - Người tạo: Admin XYZ
  - Nút: Duyệt (xanh) | Từ chối (đỏ)

---

## 🗄️ DATABASE

### Table: `reassign_requests`

| Trường | Type | Mô tả |
|--------|------|-------|
| id | bigint | PK |
| contact_id | bigint FK | Contact cần xử lý |
| from_user_id | bigint FK | Sale hiện tại (owner) |
| to_user_id | bigint FK | Sale mới - **NULLABLE** (NULL = unassign) |
| requested_by_id | bigint FK | Admin tạo request |
| approved_by_id | bigint FK | Lead phê duyệt (nullable) |
| request_type | enum | `reassign` / `unassign` |
| status | enum | `pending` / `approved` / `rejected` |
| reason | text | Lý do yêu cầu (bắt buộc) |
| rejection_reason | text | Lý do từ chối (nullable) |
| decided_at | datetime | Thời điểm duyệt/từ chối |
| created_at | datetime | |
| updated_at | datetime | |

---

## 📁 FILES CẦN TẠO

### Backend
- [ ] `app/models/reassign_request.rb` ✅ ĐÃ TẠO
- [ ] `app/services/reassign_service.rb`
- [ ] `app/jobs/reassign_request_notification_job.rb`
- [ ] `app/controllers/admin/reassign_requests_controller.rb`
- [ ] `app/controllers/teams/reassign_requests_controller.rb`

### Frontend
- [ ] `app/views/admin/contacts/index.html.erb`
- [ ] `app/views/admin/reassign_requests/_modal.html.erb`
- [ ] `app/views/teams/reassign_requests/index.html.erb`
- [ ] `app/views/teams/reassign_requests/_card.html.erb`

### Routes & Permissions
- [ ] Routes cho `/admin/contacts`, `/admin/reassign_requests`, `/teams/reassign_requests`
- [ ] CanCanCan permissions

### Tests
- [ ] RSpec model tests
- [ ] RSpec controller tests
