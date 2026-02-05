# 🛡️ Module: Dynamic Permissions

> **Module ID**: PERM  
> **Priority**: Cao ⭐  
> **Phase**: 1  
> **Note**: Đây là module QUAN TRỌNG NHẤT của hệ thống

---

## 1. Tổng Quan

Hệ thống phân quyền động cho phép:
- Admin tạo **Roles** mới với bộ permissions tùy chọn
- Gán **Role** cho users
- **Override** permissions cho từng user cụ thể

### 1.1 Mô Hình Phân Quyền

```
┌─────────────────────────────────────────────────────────────┐
│                      PERMISSION MODEL                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐      ┌─────────┐      ┌─────────────────────┐ │
│  │  USER   │──────│  ROLE   │──────│    PERMISSIONS      │ │
│  └────┬────┘      └─────────┘      └─────────────────────┘ │
│       │                                                     │
│       │           ┌─────────────────────────────────────┐   │
│       └──────────▶│  USER PERMISSION OVERRIDES          │   │
│                   │  (Grant hoặc Deny cụ thể)           │   │
│                   └─────────────────────────────────────┘   │
│                                                             │
│  Final Permission = Role Permissions + User Overrides       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| PERM-001 | Admin tạo/sửa/xóa Roles | Cao | 1 |
| PERM-002 | Mỗi Role có tập hợp Permissions | Cao | 1 |
| PERM-003 | Gán 1 hoặc nhiều Roles cho User | Cao | 1 |
| PERM-004 | Override (grant/deny) permission cho User | Cao | 1 |
| PERM-005 | UI quản lý permissions trực quan | Cao | 1 |
| PERM-006 | Không cho xóa system roles (Admin) | Cao | 1 |
| PERM-007 | Clone role từ role có sẵn | Trung | 1 |

---

## 3. Danh Sách Permissions

### 3.1 Contacts

| Code | Name | Description |
|------|------|-------------|
| `contacts.view` | Xem contacts | Xem danh sách và chi tiết |
| `contacts.create` | Tạo contact | Thêm mới |
| `contacts.pick` | Pick contact | Nhận contact để xử lý |
| `contacts.edit` | Sửa contact | Cập nhật thông tin |
| `contacts.update_status` | Cập nhật status | Chuyển trạng thái |
| `contacts.view_failed` | Xem contacts fail | Cho CSKH |

### 3.2 Teams

| Code | Name | Description |
|------|------|-------------|
| `teams.view` | Xem teams | Xem danh sách teams |
| `teams.manage` | Quản lý teams | CRUD teams |

### 3.3 Products & Coupons

| Code | Name | Description |
|------|------|-------------|
| `products.view` | Xem products | Xem danh sách |
| `products.manage` | Quản lý products | CRUD products |
| `coupons.view` | Xem coupons | Xem danh sách |
| `coupons.manage` | Quản lý coupons | CRUD coupons |

### 3.4 Deals

| Code | Name | Description |
|------|------|-------------|
| `deals.view` | Xem deals | Xem danh sách deals |
| `deals.create` | Tạo deal | Khi chốt contact |
| `deals.edit` | Sửa deal | Cập nhật thông tin |
| `deals.update_payment` | Cập nhật thanh toán | Thay đổi status thanh toán |

### 3.5 Employees

| Code | Name | Description |
|------|------|-------------|
| `employees.view` | Xem nhân viên | Xem danh sách |
| `employees.create` | Tạo nhân viên | Thêm user mới |
| `employees.edit` | Sửa nhân viên | Cập nhật thông tin |
| `employees.delete` | Xóa nhân viên | Vô hiệu hóa tài khoản |
| `employees.manage_roles` | Quản lý roles | Gán/bỏ roles |

### 3.6 Permissions & Roles

| Code | Name | Description |
|------|------|-------------|
| `roles.view` | Xem roles | Xem danh sách roles |
| `roles.manage` | Quản lý roles | CRUD roles |
| `permissions.override` | Override permissions | Gán permission cụ thể cho user |

### 3.7 Notifications

| Code | Name | Description |
|------|------|-------------|
| `notifications.view` | Xem notifications | Xem thông báo của mình |
| `notifications.receive` | Nhận notifications | Nhận web push |
| `notifications.send` | Gửi notification | Gửi thủ công |
| `notifications.manage_rules` | Quản lý rules | CRUD notification rules |

### 3.8 Zalo OA

| Code | Name | Description |
|------|------|-------------|
| `zalo.send` | Gửi tin Zalo | Gửi tin nhắn qua Zalo OA |

### 3.9 Logs

| Code | Name | Description |
|------|------|-------------|
| `logs.view_own` | Xem logs của mình | Chỉ xem activities của bản thân |
| `logs.view_all` | Xem tất cả logs | Admin |

### 3.10 Reports & Settings

| Code | Name | Description |
|------|------|-------------|
| `reports.view` | Xem báo cáo | Dashboard, reports |
| `reports.export` | Export báo cáo | Download reports |
| `settings.view` | Xem cài đặt | |
| `settings.manage` | Quản lý cài đặt | System settings |

---

## 4. Default Roles

| Role | Permissions | System? |
|------|-------------|---------|
| **Super Admin** | Tất cả permissions | ✅ Yes |
| **Tổng Đài** | `contacts.create`, `contacts.view`, `notifications.receive` | ❌ No |
| **Sale** | `contacts.view`, `contacts.pick`, `contacts.edit`, `contacts.update_status`, `deals.*`, `notifications.receive`, `logs.view_own` | ❌ No |
| **CSKH** | `contacts.view_failed`, `contacts.edit`, `contacts.update_status`, `zalo.send`, `notifications.receive`, `logs.view_own` | ❌ No |

---

## 5. User Stories

| ID | Vai trò | Mong muốn | Để | Priority |
|----|---------|-----------|-----|----------|
| US-010 | Admin | Tạo Role "Intern" với quyền hạn giới hạn | Phân quyền cho thực tập sinh | Cao |
| US-011 | Admin | Gán permissions cho Role bằng checkbox | Dễ dàng cấu hình | Cao |
| US-012 | Admin | Gán Role "Sales" cho user mới | User có đúng quyền | Cao |
| US-013 | Admin | Grant thêm `reports.view` cho 1 Sales cụ thể | Trường hợp đặc biệt | Cao |
| US-014 | Admin | Deny `customers.delete` cho 1 Manager cụ thể | Giới hạn quyền cá nhân | Cao |
| US-015 | Admin | Xem ma trận Role-Permission | Hiểu tổng quan phân quyền | Trung |
| US-016 | Admin | Clone role "Sales" thành "Senior Sales" | Tạo role nhanh | Trung |

---

## 6. Acceptance Criteria

### AC-PERM-004: Override Permission

**Given**: User "Nguyen A" có role "Sales" (không có `reports.view`)  
**When**: Admin grant thêm `reports.view` cho user này  
**Then**:
- [ ] User có thể xem Reports
- [ ] Override hiển thị rõ trong UI (màu khác)
- [ ] Nếu bỏ role Sales, override vẫn còn

**When**: Admin deny `customers.delete` cho user có role "Manager"  
**Then**:
- [ ] User KHÔNG thể xóa customer dù role có quyền
- [ ] Deny override hiển thị rõ (màu đỏ)

---

## 7. UI/UX Notes

### 7.1 Role Management

```
┌─────────────────────────────────────────────────────────────────────┐
│ 🛡️ Quản Lý Roles                              [+ Tạo Role Mới]     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────┬──────────────┬──────────┬──────────────────────┐ │
│  │ Tên Role      │ Mô tả        │ Users    │ Actions              │ │
│  ├───────────────┼──────────────┼──────────┼──────────────────────┤ │
│  │ 🔒 Admin      │ Toàn quyền   │ 2        │ [Xem]                │ │
│  │ Manager       │ Quản lý team │ 5        │ [Sửa] [Clone] [Xóa]  │ │
│  │ Sales         │ Nhân viên KD │ 50       │ [Sửa] [Clone] [Xóa]  │ │
│  │ Intern        │ Thực tập     │ 10       │ [Sửa] [Clone] [Xóa]  │ │
│  └───────────────┴──────────────┴──────────┴──────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.2 Permission Matrix (Edit Role)

```
┌─────────────────────────────────────────────────────────────────────┐
│ 🛡️ Chỉnh Sửa Role: Sales                                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  📁 CUSTOMERS                                                       │
│  ├── [✅] customers.view      Xem khách hàng                        │
│  ├── [✅] customers.create    Tạo khách hàng                        │
│  ├── [✅] customers.edit      Sửa khách hàng                        │
│  └── [❌] customers.delete    Xóa khách hàng                        │
│                                                                     │
│  📁 EMPLOYEES                                                       │
│  ├── [❌] employees.view      Xem nhân viên                         │
│  ├── [❌] employees.create    Tạo nhân viên                         │
│  └── ...                                                            │
│                                                                     │
│  📁 REPORTS                                                         │
│  ├── [❌] reports.view        Xem báo cáo                           │
│  └── [❌] reports.export      Export báo cáo                        │
│                                                                     │
│                          [ Hủy ]  [ 💾 Lưu ]                        │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.3 User Permission Override

```
┌─────────────────────────────────────────────────────────────────────┐
│ 👤 Phân Quyền User: Nguyễn Văn A                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Roles: [Sales ✕]  [+ Thêm Role]                                    │
│                                                                     │
│  ─────────────────────────────────────────────────────────────────  │
│  Permission Overrides:                                              │
│                                                                     │
│  Permission          │ Từ Role │ Override │                        │
│  ────────────────────┼─────────┼──────────┤                        │
│  customers.view      │ ✅      │ -        │                        │
│  customers.create    │ ✅      │ -        │                        │
│  customers.delete    │ ❌      │ -        │                        │
│  reports.view        │ ❌      │ 🟢 GRANT │ [Bỏ override]          │
│  employees.edit      │ ❌      │ 🔴 DENY  │ [Bỏ override]          │
│                                                                     │
│  [+ Thêm Override]                                                  │
│                                                                     │
│                          [ Hủy ]  [ 💾 Lưu ]                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 8. API Endpoints

### Roles

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/roles` | List roles | `roles.view` |
| GET | `/api/v1/roles/:id` | Role detail | `roles.view` |
| POST | `/api/v1/roles` | Create role | `roles.manage` |
| PUT | `/api/v1/roles/:id` | Update role | `roles.manage` |
| DELETE | `/api/v1/roles/:id` | Delete role | `roles.manage` |
| POST | `/api/v1/roles/:id/clone` | Clone role | `roles.manage` |

### Permissions

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/permissions` | List all permissions | `roles.view` |

### User Permissions

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/users/:id/permissions` | Get user effective permissions | `employees.view` |
| PUT | `/api/v1/users/:id/permissions` | Override user permissions | `permissions.override` |
| PUT | `/api/v1/users/:id/roles` | Assign roles to user | `employees.manage_roles` |

---

## 9. Database Tables

### roles

| Column | Type | Description |
|--------|------|-------------|
| id | int | PK |
| name | string | Unique |
| description | text | |
| is_system | boolean | Không cho xóa/sửa nếu true |
| created_at | datetime | |
| updated_at | datetime | |

### permissions

| Column | Type | Description |
|--------|------|-------------|
| id | int | PK |
| code | string | Unique, e.g. `customers.view` |
| name | string | Display name |
| category | string | Group: customers, employees, etc. |

### role_permissions

| Column | Type | Description |
|--------|------|-------------|
| role_id | int | FK |
| permission_id | int | FK |

### user_roles

| Column | Type | Description |
|--------|------|-------------|
| user_id | int | FK |
| role_id | int | FK |

### user_permission_overrides

| Column | Type | Description |
|--------|------|-------------|
| id | int | PK |
| user_id | int | FK |
| permission_id | int | FK |
| grant_type | enum | 'grant' hoặc 'deny' |
| created_at | datetime | |
| created_by | int | FK to users |

---

## 10. Permission Check Logic

```ruby
# Pseudocode
def user_has_permission?(user, permission_code)
  # 1. Check user override first
  override = user.permission_overrides.find_by(permission: permission_code)
  return override.grant_type == 'grant' if override.present?
  
  # 2. Check role permissions
  user.roles.any? do |role|
    role.permissions.exists?(code: permission_code)
  end
end
```

---

> **Related**: 
> - [04-employees.md](./04-employees.md) - Gán roles cho users
> - [06-logs.md](./06-logs.md) - Log khi thay đổi permissions
