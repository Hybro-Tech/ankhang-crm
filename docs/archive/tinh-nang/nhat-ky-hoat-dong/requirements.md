# 📋 Module: Activity Logs

> **Module ID**: LOG  
> **Priority**: Cao  
> **Phase**: 1

---

## 1. Tổng Quan

Module ghi log tất cả hoạt động của users trong hệ thống để:
- Audit trail (ai làm gì, khi nào)
- Debug issues
- Compliance requirements
- Khôi phục dữ liệu nếu cần

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| LOG-001 | Log tất cả CRUD operations | Cao | 1 |
| LOG-002 | Log authentication events | Cao | 1 |
| LOG-003 | Log permission changes | Cao | 1 |
| LOG-004 | Xem danh sách logs (pagination) | Cao | 1 |
| LOG-005 | Tìm kiếm logs (full-text) | Cao | 1 |
| LOG-006 | Lọc theo user, action, date range | Cao | 1 |
| LOG-007 | Xem chi tiết thay đổi (diff) | Trung | 1 |
| LOG-008 | Export logs | Thấp | 2 |
| LOG-009 | Auto-archive logs cũ | Trung | 1 |

---

## 3. Log Entry Structure

### 3.1 Fields

| Field | Type | Description |
|-------|------|-------------|
| id | bigint | PK |
| user_id | int | FK, người thực hiện |
| action | string | Loại action |
| resource_type | string | Model bị ảnh hưởng |
| resource_id | int | ID của record |
| changes | json | Thay đổi before/after |
| ip_address | string | IP của user |
| user_agent | string | Browser/device info |
| created_at | datetime | Thời điểm |

### 3.2 Example Log Entry

```json
{
  "id": 12345,
  "user_id": 5,
  "action": "customer.update",
  "resource_type": "Customer",
  "resource_id": 123,
  "changes": {
    "status": {
      "from": "contacted",
      "to": "in_progress"
    },
    "notes": {
      "from": "First contact",
      "to": "First contact. Meeting scheduled."
    }
  },
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "created_at": "2026-01-18T20:30:00Z"
}
```

---

## 4. Actions to Log

### 4.1 Authentication

| Action | Description |
|--------|-------------|
| `auth.login` | Đăng nhập thành công |
| `auth.login_failed` | Đăng nhập thất bại |
| `auth.logout` | Đăng xuất |
| `auth.password_changed` | Đổi mật khẩu |
| `auth.password_reset` | Reset password |

### 4.2 Contacts

| Action | Description |
|--------|-------------|
| `contact.create` | Tổng đài tạo contact mới |
| `contact.pick` | Sale pick contact |
| `contact.update` | Cập nhật thông tin |
| `contact.status_changed` | Chuyển trạng thái |
| `contact.interaction_added` | Thêm lịch sử trao đổi |

### 4.3 Deals

| Action | Description |
|--------|-------------|
| `deal.create` | Tạo deal khi chốt |
| `deal.update` | Cập nhật deal |
| `deal.payment_changed` | Thay đổi trạng thái thanh toán |

### 4.4 Teams

| Action | Description |
|--------|-------------|
| `team.create` | Tạo team mới |
| `team.update` | Cập nhật team |
| `team.delete` | Xóa team |
| `team.member_added` | Thêm thành viên |
| `team.member_removed` | Xóa thành viên |

### 4.5 Employees

| Action | Description |
|--------|-------------|
| `employee.create` | Tạo NV mới |
| `employee.update` | Cập nhật NV |
| `employee.activate` | Kích hoạt |
| `employee.deactivate` | Vô hiệu hóa |
| `employee.roles_changed` | Đổi roles |
| `employee.permissions_changed` | Override permissions |

### 4.6 Roles & Permissions

| Action | Description |
|--------|-------------|
| `role.create` | Tạo role mới |
| `role.update` | Cập nhật role |
| `role.delete` | Xóa role |
| `role.permissions_changed` | Đổi permissions của role |

### 4.7 Notifications

| Action | Description |
|--------|-------------|
| `notification_rule.create` | Tạo rule |
| `notification_rule.update` | Cập nhật rule |
| `notification_rule.toggle` | Bật/tắt rule |
| `notification.sent` | Gửi notification |
| `zalo.message_sent` | Gửi tin nhắn Zalo OA |

---

## 5. Status History Table

Bảng lưu lịch sử chuyển trạng thái của Contact.

| Field | Type | Mô tả |
|-------|------|-------|
| id | bigint | PK |
| contact_id | int | FK → Contact |
| old_status | enum | Trạng thái cũ |
| new_status | enum | Trạng thái mới |
| changed_by | int | FK → User |
| reason | text | Lý do chuyển (optional) |
| created_at | datetime | Thời điểm chuyển |

---

## 6. Payment History Table

Bảng lưu lịch sử thay đổi thanh toán của Deal.

| Field | Type | Mô tả |
|-------|------|-------|
| id | bigint | PK |
| deal_id | int | FK → Deal |
| old_status | enum | Trạng thái cũ |
| new_status | enum | Trạng thái mới |
| amount | decimal | Số tiền thay đổi |
| changed_by | int | FK → User |
| notes | text | Ghi chú |
| created_at | datetime | Thời điểm |

---

## 5. User Stories

| ID | Vai trò | Mong muốn | Để | Priority |
|----|---------|-----------|-----|----------|
| US-050 | Admin | Xem ai đã chỉnh sửa KH nào | Audit | Cao |
| US-051 | Admin | Tìm logs theo từ khóa | Debug nhanh | Cao |
| US-052 | Admin | Lọc logs theo thời gian | Tìm events cụ thể | Cao |
| US-053 | Admin | Xem exactly gì đã thay đổi | Hiểu rõ changes | Trung |
| US-054 | Manager | Xem logs của team mình | Theo dõi team | Trung |
| US-055 | User | Xem logs của chính mình | Biết mình đã làm gì | Thấp |

---

## 6. Acceptance Criteria

### AC-LOG-005: Tìm kiếm

**Given**: Tôi ở trang Activity Logs  
**When**: Tôi nhập "customer" vào search  
**Then**:
- [ ] Tìm trong: action, resource_type, changes
- [ ] Kết quả < 1 giây
- [ ] Highlight từ khóa

### AC-LOG-007: Xem diff

**Given**: Có log entry với changes  
**When**: Click vào entry  
**Then**:
- [ ] Hiển thị before/after side by side
- [ ] Highlight fields thay đổi
- [ ] Hiển thị readable field names (không phải column names)

---

## 7. UI/UX Notes

### 7.1 Log Viewer

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 📋 Activity Logs                                          [📥 Export CSV]  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ 🔍 [Tìm kiếm...________]  User: [Tất cả ▼]  Action: [Tất cả ▼]             │
│ From: [2026-01-01]  To: [2026-01-18]  [🔎 Tìm]  [↻ Reset]                   │
│                                                                             │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ Thời gian         │ User       │ Action          │ Resource     │ IP   │ │
│ ├───────────────────┼────────────┼─────────────────┼──────────────┼──────┤ │
│ │ 18/01 20:30       │ nguyen.a   │ 📝 customer.update│ KH #123    │ 1.2.3│ │
│ │ 18/01 20:25       │ tran.b     │ ➕ customer.create│ KH #124    │ 1.2.4│ │
│ │ 18/01 20:20       │ admin      │ 🛡️ role.update    │ Role #2    │ 1.2.5│ │
│ │ 18/01 20:15       │ le.c       │ 🔐 auth.login     │ -          │ 1.2.6│ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│ Showing 1-25 of 10,523 logs                      < 1 2 3 ... 421 >         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Log Detail Modal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 📋 Log Detail                                                     [✕]      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📅 Thời gian: 18/01/2026 20:30:45                                          │
│  👤 User: Nguyễn Văn A (nguyen.a)                                           │
│  🎯 Action: customer.update                                                 │
│  📦 Resource: Customer #123 (Trần B)                                        │
│  🌐 IP: 192.168.1.100                                                       │
│  💻 Device: Chrome on Windows                                               │
│                                                                             │
│  ─────────────────────────────────────────────────────────────────────────  │
│  📝 Thay đổi:                                                               │
│  ┌────────────────────────────────┬────────────────────────────────────────┐│
│  │          BEFORE                │              AFTER                    ││
│  ├────────────────────────────────┼────────────────────────────────────────┤│
│  │ Status: 🟡 Đã liên hệ          │ Status: 🟠 Đang xử lý                  ││
│  │ Notes: "First contact"         │ Notes: "First contact. Meeting..."    ││
│  └────────────────────────────────┴────────────────────────────────────────┘│
│                                                                             │
│                                                        [ Đóng ]             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. API Endpoints

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/logs` | List logs (paginated) | `logs.view_all` |
| GET | `/api/v1/logs/:id` | Log detail | `logs.view_all` |
| GET | `/api/v1/logs/my` | Logs của current user | `logs.view_own` |

### Query Parameters

| Param | Type | Description |
|-------|------|-------------|
| `q` | string | Search text |
| `user_id` | int | Filter by user |
| `action` | string | Filter by action (prefix match) |
| `resource_type` | string | Filter by resource |
| `from` | datetime | Start date |
| `to` | datetime | End date |
| `page` | int | Page number |
| `per_page` | int | Items per page (max 100) |

---

## 9. Database Table

### activity_logs

| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | PK, auto |
| user_id | int | FK, nullable (system actions) |
| action | varchar(100) | NOT NULL, indexed |
| resource_type | varchar(100) | indexed |
| resource_id | int | indexed |
| changes | json | |
| ip_address | varchar(45) | IPv6 support |
| user_agent | varchar(255) | |
| created_at | datetime | NOT NULL, indexed |

### Indexes

```sql
CREATE INDEX idx_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_logs_action ON activity_logs(action);
CREATE INDEX idx_logs_resource ON activity_logs(resource_type, resource_id);
CREATE INDEX idx_logs_created_at ON activity_logs(created_at);
CREATE FULLTEXT INDEX idx_logs_search ON activity_logs(action, resource_type);
```

### Partitioning (Optimization)

```sql
-- Partition by month for better performance
ALTER TABLE activity_logs
PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
    PARTITION p202601 VALUES LESS THAN (202602),
    PARTITION p202602 VALUES LESS THAN (202603),
    -- ...
);
```

---

## 10. Implementation

### 10.1 Logging Concern

```ruby
# app/models/concerns/auditable.rb
module Auditable
  extend ActiveSupport::Concern

  included do
    after_create  { log_activity('create') }
    after_update  { log_activity('update') }
    after_destroy { log_activity('delete') }
  end

  private

  def log_activity(action)
    ActivityLog.create!(
      user_id: Current.user&.id,
      action: "#{self.class.name.underscore}.#{action}",
      resource_type: self.class.name,
      resource_id: self.id,
      changes: changes_for_log,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end

  def changes_for_log
    return {} unless action == 'update'
    saved_changes.except('updated_at').transform_values do |change|
      { from: change[0], to: change[1] }
    end
  end
end
```

### 10.2 Usage

```ruby
class Customer < ApplicationRecord
  include Auditable
end
```

---

## 11. Storage Optimization

### 11.1 Archive Strategy

| Age | Location | Access |
|-----|----------|--------|
| < 3 months | Primary DB | Fast |
| 3-12 months | Archive table | Medium |
| > 12 months | Cold storage (S3) | Slow |

### 11.2 Cleanup Job

```ruby
# Chạy hàng ngày
class LogArchiveJob
  def perform
    # Move logs > 3 months to archive
    ActivityLog.where('created_at < ?', 3.months.ago)
               .find_in_batches do |batch|
      ArchivedActivityLog.insert_all(batch.map(&:attributes))
      batch.each(&:destroy)
    end
  end
end
```

---

## 12. Permissions

| Action | Permission |
|--------|------------|
| Xem tất cả logs | `logs.view_all` |
| Xem logs của mình | `logs.view_own` |
| Export logs | `logs.view_all` + `reports.export` |

---

> **Related**: 
> - Tất cả modules khác đều trigger logs
> - [08-database.md](./08-database.md) - Full schema
