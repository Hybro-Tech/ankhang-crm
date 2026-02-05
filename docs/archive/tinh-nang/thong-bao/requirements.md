# 🔔 Module: Notifications

> **Module ID**: NOTI  
> **Priority**: Cao ⭐  
> **Phase**: 1  
> **Note**: Module QUAN TRỌNG - đa kênh, không độ trễ

---

## 1. Tổng Quan

Hệ thống thông báo đa kênh cho phép:
- Gửi notifications qua 5+ channels
- Admin tạo rules để filter người nhận
- Đảm bảo 100-200 users nhận cùng lúc, không trễ

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| NOTI-001 | Gửi notification qua Email | Cao | 1 |
| NOTI-002 | Gửi notification qua Slack | Cao | 1 |
| NOTI-003 | Gửi notification qua Web Push | Cao | 1 |
| NOTI-004 | Gửi notification qua Zalo OA | Trung | 1 |
| NOTI-005 | Gửi notification qua Facebook | Trung | 1 |
| NOTI-006 | Real-time in-app (WebSocket) | Trung | 2 |
| NOTI-007 | Admin tạo notification rules | Cao | 1 |
| NOTI-008 | Rule filter theo conditions | Cao | 1 |
| NOTI-009 | Enable/Disable rules | Cao | 1 |
| NOTI-010 | Test rule trước khi activate | Trung | 1 |
| NOTI-011 | Xem lịch sử notifications đã gửi | Trung | 1 |
| NOTI-012 | Gửi notification thủ công | Trung | 1 |

---

## 3. Notification Channels

### 3.1 Channel Details

| Channel | Setup Required | Notes |
|---------|----------------|-------|
| **Email** | SMTP server hoặc SendGrid API | Required |
| **Slack** | Slack Webhook URL | Workspace invitation |
| **Web Push** | VAPID keys + Service Worker | Browser permission |
| **Zalo OA** | Zalo Official Account API | Cần ZNS template |
| **Facebook** | Facebook Page + Access Token | Page subscription |
| **In-app** | WebSocket (ActionCable) | Phase 2 |

### 3.2 Channel Comparison

| Channel | Speed | Reliability | Cost | Reach |
|---------|-------|-------------|------|-------|
| Email | Medium | High | Low | All |
| Slack | Fast | High | Free | Team |
| Web Push | Fast | Medium | Free | Desktop/Mobile |
| Zalo | Fast | High | Per msg | Vietnam |
| Facebook | Fast | Medium | Free | Page followers |

---

## 4. Notification Rules

### 4.1 Rule Structure

```yaml
rule:
  id: 1
  name: "Thông báo Contact mới cho Sales Team HN"
  enabled: true
  
  # When this event happens
  trigger_event: "contact.created"
  
  # Send to users matching these conditions
  conditions:
    - field: "recipient.roles"
      operator: "contains"
      value: "Sale"
    - field: "recipient.team"
      operator: "equals"
      value: "Team Hà Nội"
  
  # Via these channels
  channels:
    - web_push
    - email
  
  # Message template
  template:
    title: "Contact mới: {{contact.customer_name}}"
    body: "SĐT: {{contact.phone}} | Nhu cầu: {{contact.need_type}}"
```

### 4.2 Trigger Events

| Event | Description | Data Available |
|-------|-------------|----------------|
| `contact.created` | Khi Tổng đài tạo contact mới | contact.* |
| `contact.picked` | Khi Sales pick contact | contact.*, picked_by.* |
| `contact.status_changed` | Khi đổi status | contact.*, old_status, new_status |
| `deal.created` | Khi chốt deal | deal.*, contact.* |
| `response.negative` | Khi phản hồi tiêu cực (AI) | contact.*, response.* |
| `system.broadcast` | Admin gửi thủ công | custom message |

### 4.3 Condition Fields

| Field | Type | Operators |
|-------|------|-----------|
| `recipient.roles` | array | contains, not_contains |
| `recipient.department` | string | equals, not_equals, in |
| `recipient.id` | int | equals, in |
| `recipient.active` | boolean | equals |
| `customer.status` | string | equals, not_equals |

### 4.4 Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `equals` | Bằng | `department equals "Hanoi"` |
| `not_equals` | Khác | `status not_equals "completed"` |
| `contains` | Chứa (array) | `roles contains "Sales"` |
| `in` | Trong danh sách | `id in [1, 2, 3]` |
| `greater_than` | Lớn hơn | `created_at greater_than "1 day ago"` |

---

## 5. User Stories

| ID | Vai trò | Mong muốn | Để | Priority |
|----|---------|-----------|-----|----------|
| US-040 | Admin | Tạo rule "Báo Sales HN khi có lead mới" | Tự động thông báo | Cao |
| US-041 | Admin | Test rule với dữ liệu mẫu | Kiểm tra trước khi bật | Trung |
| US-042 | Admin | Bật/tắt rule nhanh | Kiểm soát notifications | Cao |
| US-043 | Admin | Xem log notifications đã gửi | Theo dõi, debug | Trung |
| US-044 | Admin | Gửi broadcast đến tất cả | Thông báo quan trọng | Trung |
| US-045 | User | Nhận thông báo không trễ | Không bị bỏ lỡ | Cao |
| US-046 | User | Nhận qua nhiều kênh | Không miss | Cao |

---

## 6. Acceptance Criteria

### AC-NOTI-001: Gửi không trễ

**Given**: Rule "Báo Sales khi có lead mới" đang bật  
**Given**: Có 100 Sales users  
**When**: Tạo customer mới  
**Then**:
- [ ] Tất cả 100 users nhận notification < 5 giây
- [ ] Mỗi user nhận đúng 1 lần (không duplicate)
- [ ] Gửi song song qua tất cả channels trong rule

### AC-NOTI-007: Tạo rule

**Given**: Tôi là Admin ở trang tạo rule  
**When**: Điền đủ thông tin và save  
**Then**:
- [ ] Rule được lưu với status disabled
- [ ] Có thể test rule ngay
- [ ] Sau test thành công, bật được rule

---

## 7. UI/UX Notes

### 7.1 Danh Sách Rules

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 🔔 Notification Rules                            [+ Tạo Rule Mới]       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│ ┌───────────────────────────────────────────────────────────────────┐   │
│ │ Status │ Tên Rule                   │ Trigger        │ Channels  │   │
│ ├────────┼────────────────────────────┼────────────────┼───────────┤   │
│ │ 🟢 ON  │ Lead mới → Sales HN        │ customer.created│ 📧🔔💬   │   │
│ │ 🟢 ON  │ Status → Completed         │ status_changed │ 📧       │   │
│ │ 🔴 OFF │ Daily Summary              │ scheduled      │ 📧       │   │
│ └───────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Rule Builder

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 📢 Tạo Notification Rule                                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Tên Rule *                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ Lead mới cho Sales Hà Nội                                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  🎯 Trigger Event *                                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ Khi tạo khách hàng mới (customer.created)                   ▼   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  👥 Điều kiện người nhận                                                │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ ┌─────────────┐ ┌──────────┐ ┌─────────────┐                    │   │
│  │ │ Roles    ▼  │ │ chứa  ▼  │ │ Sales    ▼  │  [🗑️]             │   │
│  │ └─────────────┘ └──────────┘ └─────────────┘                    │   │
│  │ ┌─────────────┐ ┌──────────┐ ┌─────────────┐                    │   │
│  │ │ Department▼ │ │ bằng  ▼  │ │ Hanoi    ▼  │  [🗑️]             │   │
│  │ └─────────────┘ └──────────┘ └─────────────┘                    │   │
│  │                                                                 │   │
│  │ [+ Thêm điều kiện]                         Logic: [AND ▼]       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  📮 Gửi qua                                                             │
│  [✅] 📧 Email  [✅] 💬 Slack  [✅] 🔔 Web Push  [ ] Zalo  [ ] FB       │
│                                                                         │
│  📝 Message Template                                                    │
│  Title: ┌──────────────────────────────────────────────────────────┐   │
│         │ Lead mới: {{customer.name}}                              │   │
│         └──────────────────────────────────────────────────────────┘   │
│  Body:  ┌──────────────────────────────────────────────────────────┐   │
│         │ SĐT: {{customer.phone}}                                  │   │
│         │ Người tạo: {{created_by.name}}                           │   │
│         └──────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Variables: {{customer.name}}, {{customer.phone}}, {{created_by.name}} │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────────  │
│  Status: [🔴 Tắt] [Toggle to enable after testing]                      │
│                                                                         │
│           [ Hủy ]  [ 🧪 Test Rule ]  [ 💾 Lưu ]                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Test Rule Modal

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 🧪 Test Rule: Lead mới cho Sales HN                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Dữ liệu test:                                                          │
│  Customer: Nguyễn Test - 0901234567                                     │
│                                                                         │
│  📊 Kết quả:                                                            │
│  ✅ Tìm thấy 15 người nhận matching conditions                          │
│                                                                         │
│  Người nhận:                                                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ • Trần A (Sales, Hanoi)                                         │   │
│  │ • Lê B (Sales, Hanoi)                                           │   │
│  │ • ... và 13 người khác                                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Message preview:                                                       │
│  Title: "Lead mới: Nguyễn Test"                                         │
│  Body: "SĐT: 0901234567"                                                │
│                                                                         │
│  [ ] Gửi thật qua email đến người nhận test                             │
│                                                                         │
│                              [ Đóng ]  [ 📧 Gửi Test ]                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 8. API Endpoints

### Rules Management

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/notification-rules` | List rules | `notifications.manage_rules` |
| GET | `/api/v1/notification-rules/:id` | Rule detail | `notifications.manage_rules` |
| POST | `/api/v1/notification-rules` | Create rule | `notifications.manage_rules` |
| PUT | `/api/v1/notification-rules/:id` | Update rule | `notifications.manage_rules` |
| DELETE | `/api/v1/notification-rules/:id` | Delete rule | `notifications.manage_rules` |
| PUT | `/api/v1/notification-rules/:id/toggle` | Enable/Disable | `notifications.manage_rules` |
| POST | `/api/v1/notification-rules/:id/test` | Test rule | `notifications.manage_rules` |

### Manual Notifications

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| POST | `/api/v1/notifications/broadcast` | Gửi đến tất cả | `notifications.send` |
| POST | `/api/v1/notifications/send` | Gửi đến users cụ thể | `notifications.send` |
| GET | `/api/v1/notifications/history` | Lịch sử đã gửi | `notifications.view` |

---

## 9. Database Tables

### notification_rules

| Column | Type | Description |
|--------|------|-------------|
| id | int | PK |
| name | varchar(255) | NOT NULL |
| trigger_event | varchar(100) | NOT NULL |
| conditions | json | Filter conditions |
| channels | json | Array of channels |
| template_title | varchar(255) | |
| template_body | text | |
| enabled | boolean | Default false |
| created_by | int | FK users |
| created_at | datetime | |
| updated_at | datetime | |

### notification_logs

| Column | Type | Description |
|--------|------|-------------|
| id | bigint | PK |
| rule_id | int | FK, nullable (manual send) |
| trigger_event | varchar(100) | |
| recipient_count | int | |
| channels | json | |
| status | enum | pending, sent, partial, failed |
| sent_at | datetime | |
| metadata | json | Additional data |

### notification_deliveries

| Column | Type | Description |
|--------|------|-------------|
| id | bigint | PK |
| notification_log_id | bigint | FK |
| user_id | int | FK |
| channel | varchar(50) | |
| status | enum | pending, sent, failed |
| sent_at | datetime | |
| error_message | text | If failed |

---

## 10. Technical Implementation

### 10.1 Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         NOTIFICATION FLOW                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────┐    ┌────────────┐    ┌────────────┐    ┌─────────────┐  │
│  │  Trigger  │───▶│  Match     │───▶│   Queue    │───▶│   Workers   │  │
│  │  Event    │    │  Rules     │    │  (Redis)   │    │  (Sidekiq)  │  │
│  └───────────┘    └────────────┘    └────────────┘    └──────┬──────┘  │
│                                                              │         │
│                    ┌─────────────────────────────────────────┘         │
│                    ▼                                                    │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                     Channel Adapters                              │  │
│  ├─────────┬─────────┬──────────┬─────────┬──────────┬──────────────┤  │
│  │  Email  │  Slack  │ Web Push │  Zalo   │ Facebook │   In-App     │  │
│  └─────────┴─────────┴──────────┴─────────┴──────────┴──────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Performance Requirements

| Requirement | Target | Solution |
|-------------|--------|----------|
| 100-200 users cùng lúc | < 5 giây | Parallel workers |
| No message loss | 99.9% | Retry queue |
| No duplicates | 100% | Idempotency key |

### 10.3 Worker Configuration

```ruby
# Sidekiq config
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

# NotificationWorker - parallel processing
class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'notifications', 
                  retry: 3,
                  concurrency: 20  # 20 workers song song
end
```

---

## 11. Channel Integration Guide

### 11.1 Email (SendGrid)

```ruby
# .env
SENDGRID_API_KEY=SG.xxxxx

# Mailer
class NotificationMailer < ApplicationMailer
  def notify(user, title, body)
    mail(to: user.email, subject: title)
  end
end
```

### 11.2 Slack (Webhook)

```ruby
# .env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxx

# Notifier
def send_slack(webhook_url, message)
  HTTParty.post(webhook_url, body: { text: message }.to_json)
end
```

### 11.3 Web Push (VAPID)

```ruby
# .env
VAPID_PUBLIC_KEY=xxx
VAPID_PRIVATE_KEY=xxx

# Service Worker registration required on frontend
```

---

> **Related**: 
> - [06-logs.md](./06-logs.md) - Log khi gửi notifications
> - [08-database.md](./08-database.md) - Full schema
