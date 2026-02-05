# 👤 Module: Employees

> **Module ID**: EMP  
> **Priority**: Cao  
> **Phase**: 1

---

## 1. Tổng Quan

Module quản lý nhân viên (users) trong hệ thống, bao gồm tạo account, gán roles, gán team, và quản lý trạng thái.

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| EMP-001 | Thêm nhân viên mới | Cao | 1 |
| EMP-002 | Xem danh sách nhân viên | Cao | 1 |
| EMP-003 | Xem chi tiết nhân viên | Cao | 1 |
| EMP-004 | Sửa thông tin nhân viên | Cao | 1 |
| EMP-005 | Vô hiệu hóa tài khoản | Cao | 1 |
| EMP-006 | Kích hoạt lại tài khoản | Cao | 1 |
| EMP-007 | Reset password | Cao | 1 |
| EMP-008 | Gán roles cho nhân viên | Cao | 1 |
| EMP-009 | Gán team cho nhân viên | Cao | 1 |
| EMP-010 | Override permissions | Cao | 1 |
| EMP-011 | Tìm kiếm nhân viên | Trung | 1 |

---

## 3. Thông Tin Nhân Viên

### 3.1 Fields

| Field | Type | Required | Validation | Ghi chú |
|-------|------|----------|------------|---------|
| id | int | Auto | | PK |
| username | string(50) | ✅ | Unique, alphanum | Login |
| password_hash | string | ✅ | bcrypt | Không hiển thị |
| email | string(255) | ✅ | Unique, email format | |
| name | string(255) | ✅ | Min 2 chars | Họ và tên |
| phone | string(20) | | Phone format | |
| team_id | int | | FK teams | Team thuộc về |
| position | string(100) | | | Chức vụ |
| active | boolean | ✅ | Default true | Trạng thái |
| last_login_at | datetime | | | Lần login cuối |
| last_pick_at | datetime | | | Lần pick contact cuối (cho Sales) |
| created_at | datetime | Auto | | |
| updated_at | datetime | Auto | | |

### 3.2 Default Roles

| Role | Mô tả |
|------|-------|
| Super Admin | Quản trị toàn bộ hệ thống |
| Tổng Đài | Tạo contacts, nhận điện thoại |
| Sale | Pick contact, tư vấn, chốt deal |
| CSKH | Chăm sóc contacts fail |

---

## 4. User Stories

| ID | Vai trò | Mong muốn | Để | Priority |
|----|---------|-----------|-----|----------|
| US-030 | Admin | Tạo account cho nhân viên mới | Họ có thể đăng nhập | Cao |
| US-031 | Admin | Gán role "Sales" cho nhân viên | Họ có đúng quyền | Cao |
| US-032 | Admin | Vô hiệu hóa account nghỉ việc | Họ không thể đăng nhập | Cao |
| US-033 | Admin | Reset password khi NV quên | Họ có thể đăng nhập lại | Cao |
| US-034 | Admin | Xem danh sách NV theo role | Quản lý dễ hơn | Trung |
| US-035 | Admin | Override permission cho NV | Xử lý trường hợp đặc biệt | Cao |

---

## 5. Acceptance Criteria

### AC-EMP-001: Tạo nhân viên

**Given**: Tôi là Admin ở trang tạo nhân viên  
**When**: Điền đủ thông tin và submit  
**Then**:
- [ ] Tạo user mới trong database
- [ ] Password được hash (bcrypt)
- [ ] Email invitation được gửi (nếu có)
- [ ] User có thể login ngay
- [ ] Ghi log action

### AC-EMP-005: Vô hiệu hóa

**Given**: Tôi là Admin xem chi tiết nhân viên  
**When**: Click "Vô hiệu hóa"  
**Then**:
- [ ] Hiện confirm dialog
- [ ] Sau confirm: active = false
- [ ] User bị logout ngay lập tức
- [ ] User không thể login
- [ ] Ghi log action

---

## 6. UI/UX Notes

### 6.1 Danh Sách Nhân Viên

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 👥 Nhân Viên                                     [+ Thêm Nhân Viên]     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│ 🔍 [Tìm kiếm...___]   Role: [Tất cả ▼]   Status: [Tất cả ▼]            │
│                                                                         │
│ ┌───────────────────────────────────────────────────────────────────┐   │
│ │ Họ tên         │ Username   │ Email          │ Roles   │ Status  │   │
│ ├────────────────┼────────────┼────────────────┼─────────┼─────────┤   │
│ │ Nguyễn Văn A   │ nguyen.a   │ a@law.com      │ Admin   │ 🟢 Active│   │
│ │ Trần Thị B     │ tran.b     │ b@law.com      │ Manager │ 🟢 Active│   │
│ │ Lê Văn C       │ le.c       │ c@law.com      │ Sales   │ 🔴 Inactive│ │
│ └───────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Form Thêm/Sửa

```
┌─────────────────────────────────────────────────────────────────────────┐
│ ➕ Thêm Nhân Viên Mới                                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  👤 Thông tin cơ bản                                                    │
│  ─────────────────────                                                  │
│  Họ và tên *              Username *                                    │
│  ┌────────────────────┐   ┌────────────────────┐                       │
│  │                    │   │                    │                       │
│  └────────────────────┘   └────────────────────┘                       │
│                                                                         │
│  Email *                  Số điện thoại                                 │
│  ┌────────────────────┐   ┌────────────────────┐                       │
│  │                    │   │                    │                       │
│  └────────────────────┘   └────────────────────┘                       │
│                                                                         │
│  Phòng ban                Chức vụ                                       │
│  ┌────────────────────┐   ┌────────────────────┐                       │
│  │                    │   │                    │                       │
│  └────────────────────┘   └────────────────────┘                       │
│                                                                         │
│  Password * (chỉ khi tạo mới)                                           │
│  ┌─────────────────────────────────────────────┐  [🔄 Generate]        │
│  │                                             │                       │
│  └─────────────────────────────────────────────┘                       │
│                                                                         │
│  🛡️ Phân quyền                                                          │
│  ─────────────────────                                                  │
│  Roles: [✓ Sales] [  Manager] [  Admin]                                │
│                                                                         │
│  [+ Override Permissions...]                                            │
│                                                                         │
│                              [ Hủy ]  [ 💾 Lưu ]                        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. API Endpoints

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/employees` | List employees | `employees.view` |
| GET | `/api/v1/employees/:id` | Employee detail | `employees.view` |
| POST | `/api/v1/employees` | Create employee | `employees.create` |
| PUT | `/api/v1/employees/:id` | Update employee | `employees.edit` |
| PUT | `/api/v1/employees/:id/toggle-status` | Activate/Deactivate | `employees.delete` |
| POST | `/api/v1/employees/:id/reset-password` | Reset password | `employees.edit` |
| PUT | `/api/v1/employees/:id/roles` | Assign roles | `employees.manage_roles` |
| PUT | `/api/v1/employees/:id/permissions` | Override permissions | `permissions.override` |

---

## 8. Database Table

### users

| Column | Type | Constraints |
|--------|------|-------------|
| id | int | PK, auto |
| username | varchar(50) | UNIQUE, NOT NULL |
| password_hash | varchar(255) | NOT NULL |
| email | varchar(255) | UNIQUE, NOT NULL |
| name | varchar(255) | NOT NULL |
| phone | varchar(20) | |
| department | varchar(100) | |
| position | varchar(100) | |
| active | boolean | NOT NULL, default true |
| last_login_at | datetime | |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

### Indexes

```sql
CREATE UNIQUE INDEX idx_users_username ON users(username);
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(active);
```

---

## 9. Business Rules

| Rule | Description |
|------|-------------|
| Không tự xóa mình | Admin không thể deactivate chính mình |
| Phải có ít nhất 1 Admin | Không cho deactivate Admin cuối cùng |
| Username không đổi | Sau khi tạo, username không thể sửa |
| Password policy | Min 8 chars, có số và chữ |

---

> **Related**: 
> - [02-permissions.md](./02-permissions.md) - Chi tiết về roles và permissions
> - [01-authentication.md](./01-authentication.md) - Login với account employee
