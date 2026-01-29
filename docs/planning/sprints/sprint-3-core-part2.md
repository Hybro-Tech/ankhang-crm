# Sprint 3: Core Features (Contacts + Real-time)

> **Duration**: 23/02/2026 - 09/03/2026 (2 tuần)  
> **Focus**: Pick Mechanism, Smart Routing, Real-time Notifications  
> **Goal**: Flow Pick hoàn thiện với real-time updates  
> **Total Tasks**: 8

---

## Epic: Contacts (Advanced)

### TASK-022: Chức năng Nhận khách (Pick) - Core
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 8 |
| **Priority** | 🔴 Critical |
| **Assignee** | Antigravity |
| **Status** | ✅ Completed |

**User Story:**
> Là Sale, tôi muốn "pick" contact mới nhưng phải tuân thủ rule của công ty.

**Description:**
Core feature với concurrency handling và dynamic rules checking.

**Acceptance Criteria:**
- [x] Nút "Nhận khách" chỉ hiện khi `contact.pickable?`
- [x] **Logic Check via PickEligibilityService**:
    - [x] Cooldown (VD: 5 phút giữa 2 lần pick)
    - [x] **Dynamic Limit**: Check số lượng đã pick trong ngày theo loại nhu cầu
- [x] DB Locking (with_lock) - tránh race condition
- [x] Update Contact: assigned_user_id, status = "potential", assigned_at
- [x] Log activity via ActivityLog

**Test Cases:**
- [x] Pick → Success (Update Assignee, Status)
- [x] Pick quá giới hạn → Error message
- [x] 2 users pick cùng lúc → Chỉ 1 thành công (DB lock)

---

### TASK-022b: Pick Rules Engine (Backend)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | Antigravity |
| **Status** | ✅ Completed |

**User Story:**
> Là Admin, tôi muốn cấu hình giới hạn nhận khách cho từng loại dịch vụ.

**Description:**
Extensible rules engine, ban đầu hardcode nhưng sẵn sàng mở rộng.

**Acceptance Criteria:**
- [x] Thêm cột `max_pick_per_day`, `pick_cooldown_minutes` vào ServiceType
- [x] Default values: 20 khách/ngày, 5 phút cooldown
- [x] Service: `PickEligibilityService.check(user, contact)` → {eligible: true/false, reason: "..."}
- [x] Admin UI: Form edit Service Type có input cho pick rules
- [x] Validations cho các giá trị (1-100, 0-60)

**Test Cases:**
- [x] PickEligibilityService trả về đúng
- [x] Admin chỉnh limit → Áp dụng ngay

**Completed:** 2026-01-29

**Implementation Notes:**
- Migration: `20260129020539_add_pick_rules_to_service_types.rb`
- Service: `app/services/pick_eligibility_service.rb`
- Form fields added to `app/views/service_types/_form.html.erb`
- Strong params updated in `ServiceTypesController`

---

### TASK-023: Chi tiết Contact & Lịch sử chăm sóc
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là Sale, tôi muốn xem chi tiết và ghi lại lịch sử chăm sóc.

**Acceptance Criteria:**
- [x] View Detail Contact với tất cả fields
- [x] Lịch sử trao đổi (Timeline view):
  - [x] Ngày giờ, Nội dung, Phương thức (Gọi điện/Zalo/Email/Gặp mặt)
  - [x] Form thêm ghi chú mới
- [x] Lịch hẹn tiếp theo (datetime picker)
- [x] Edit Contact info (quyền theo role)

**Test Cases:**
- [x] Add interaction → Appears in timeline
- [x] Set lịch hẹn → Hiển thị trên Dashboard

**Completed:** 2026-01-28

**Related:** SRS v2 Section 5.3

---

### TASK-051: Trạng thái Contact Flow (State Machine)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | Antigravity |
| **Status** | ✅ Completed |

**User Story:**
> Là Sale, tôi muốn chuyển trạng thái Contact theo đúng quy trình công ty.

**Description:**
Implement state machine theo SRS v2 Section 5.2.

**Acceptance Criteria:**
- [x] State machine: Mới → Tiềm_năng → Đang_tư_vấn → Chốt_Mới/Thất_bại
- [x] Transition rules:
  - [x] Mới → Tiềm_năng: Khi Sale nhận
  - [x] Tiềm_năng → Đang_tư_vấn: Khi Sale bắt đầu tư vấn
  - [x] Tiềm_năng → Tiềm_năng_cũ: Cronjob đầu tháng
  - [x] Đang_tư_vấn → Chốt_Mới: Thành công trong tháng
  - [x] Tiềm_năng_cũ → Chốt_Cũ: Thành công từ tháng trước
  - [x] Thất_bại → CSKH_L1: Chuyển CSKH
- [x] UI: Dropdown chọn trạng thái (chỉ hiện valid transitions)
- [x] Log mỗi lần chuyển trạng thái

**Test Cases:**
- [x] Valid transition → Success
- [x] Invalid transition (VD: Mới → Chốt) → Error
- [x] Log ghi nhận đúng

**Completed:** 2026-01-28

**Implementation Notes:**
- Concern: `app/models/concerns/status_machine.rb`
- VALID_TRANSITIONS hash với tất cả valid state changes
- `transition_to!` method với validation và logging
- `available_transitions` cho UI dropdown
- Integration với Interactions timeline

**Related:** SRS v2 Section 5.2 State Diagram

---

### TASK-052: Admin Re-assign Contact (With Approval Workflow)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 8 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn chuyển Contact cho người khác, nhưng cần Lead phê duyệt.

**Description:**
Approval workflow: Admin tạo request → Lead của Sale A approve/reject → Chuyển contact.

**Workflow:**
```
Admin tạo Request → Lead nhận Notification → Approve/Reject/Auto-approve sau X giờ
```

**Acceptance Criteria:**
- [ ] Chỉ Admin có quyền tạo request
- [ ] Modal: Chọn user mới từ dropdown (filter by team)
- [ ] Nhập lý do re-assign (bắt buộc)
- [ ] Notification đến Lead của Sale A (Manager của Team)
- [ ] Notification đến Sale A (thông báo có yêu cầu)
- [ ] Lead có thể Approve/Reject (từ notification hoặc trang danh sách)
- [ ] Nếu Reject: Yêu cầu nhập lý do
- [ ] Auto-approve sau X giờ (config trong Settings)
- [ ] Sau Approve: Update assigned_user_id, notify tất cả parties
- [ ] Log chi tiết: ai request, ai approve, lý do, thời gian

**Database:**
- [ ] Migration: `reassign_requests` table
- [ ] Model: `ReassignRequest` với state machine

**Config:**
- [ ] Setting: `reassign_auto_approve_hours` (default 24)

**Test Cases:**
- [ ] Admin tạo request → Lead nhận notification
- [ ] Lead approve → Contact chuyển, tất cả nhận notification
- [ ] Lead reject → Request hủy, Admin nhận lý do
- [ ] Timeout → Auto-approve, Lead nhận thông báo
- [ ] Non-admin tạo request → Forbidden

**Related:** SRS v3 Section 5.4

---

## Epic: Smart Routing Config

### TASK-053: Cấu hình Smart Routing (Admin)
| Field | Value |
|-------|-------|
| **Epic** | Smart Routing |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn cấu hình các tham số cho Smart Routing.

**Description:**
UI cho Admin cấu hình theo SRS v2 Section 6.2.

**Acceptance Criteria:**
- [ ] Settings table hoặc config file
- [ ] UI Settings page với:
  - [ ] Thời gian chờ (X phút) - default 2 phút
  - [ ] Mapping Loại nhu cầu → Team (multi-select)
- [ ] API: Smart Routing service đọc config này
- [ ] Realtime: Thay đổi config có hiệu lực ngay

**Test Cases:**
- [ ] Admin đổi thời gian chờ → Áp dụng ngay
- [ ] Mapping mới → Contact mới được routing đúng team

**Related:** SRS v2 Section 6.2

---

## Epic: Real-time & Notifications

### TASK-035: Cập nhật UI Real-time (ActionCable)
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn thấy contact mới xuất hiện real-time mà không cần refresh.

**Description:**
WebSocket với ActionCable + Turbo Streams.

**Acceptance Criteria:**
- [ ] ActionCable setup
- [ ] Turbo Streams subscription cho contacts channel
- [ ] Broadcast khi contact.created → List update
- [ ] Broadcast khi contact.picked → Ẩn nút "Nhận khách" cho users khác
- [ ] Connection status indicator (online/offline)

**Test Cases:**
- [ ] Contact created → Appears real-time trên Dashboard
- [ ] Contact picked → Button disappears for others
- [ ] Disconnect → Reconnect automatically

---

### TASK-032: Thông báo Web Push
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn nhận push notification khi có contact mới ngay cả khi không focus tab.

**Acceptance Criteria:**
- [ ] Service worker registration
- [ ] Push subscription management (save to DB)
- [ ] Permission request UI
- [ ] Notification content: title, body, icon, click action
- [ ] Sidekiq job cho batch sending
- [ ] Click notification → Redirect to contact

**Test Cases:**
- [ ] User grants permission → Subscription saved
- [ ] Contact created → All Sales receive push
- [ ] Click notification → Redirect to contact

---

### TASK-054: Solid Queue Scheduled Jobs (Smart Routing)
| Field | Value |
|-------|-------|
| **Epic** | Smart Routing |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là System, tôi muốn contacts tự động mở rộng visibility sau đúng X phút.

**Description:**
Setup Solid Queue (Rails 8 built-in) cho scheduled jobs với độ chính xác cao.

**Acceptance Criteria:**
- [ ] Setup Solid Queue với config polling 0.1s
- [ ] Khi contact tạo → Schedule `SmartRoutingExpandJob` sau X phút
- [ ] Job chạy → Expand visibility → Schedule tiếp nếu chưa pick
- [ ] Job tự dừng khi contact đã được assigned

**Technical Details:**
```ruby
# Khi contact được tạo (trong giờ làm việc)
SmartRoutingExpandJob.set(wait: interval.minutes).perform_later(contact.id)

# Trong job
def perform(contact_id)
  contact = Contact.find(contact_id)
  return if contact.assigned_user_id.present?  # Đã pick
  
  SmartRoutingService.new(contact).expand_visibility
  
  # Schedule tiếp
  interval = contact.service_type&.visibility_expand_minutes || 2
  SmartRoutingExpandJob.set(wait: interval.minutes).perform_later(contact_id)
end
```

**Test Cases:**
- [ ] Contact tạo lúc 10:00 với interval 2 phút → Job chạy lúc 10:02
- [ ] Job chính xác ±1 giây
- [ ] Contact được pick → Job chain dừng

---

### TASK-055: WebSocket Realtime Updates (Turbo Streams)
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn thấy contacts mới xuất hiện trên màn hình tức thì.

**Description:**
Implement ActionCable + Turbo Streams cho real-time updates.

**Acceptance Criteria:**
- [ ] ActionCable setup với Redis adapter
- [ ] User-specific channels: `user_#{id}_contacts`
- [ ] Broadcast từ model callbacks hoặc jobs:
  - [ ] Contact visible → Append to list
  - [ ] Contact picked → Remove/update row
  - [ ] Visibility expanded → Append for new users
- [ ] Connection status indicator (UI)

**Technical Details:**
```ruby
# Từ SmartRoutingExpandJob
Turbo::StreamsChannel.broadcast_append_to(
  "user_#{sale.id}_contacts",
  target: "contacts_list",
  partial: "contacts/contact_row",
  locals: { contact: contact }
)
```

**Test Cases:**
- [ ] Contact mới → Xuất hiện real-time (không reload)
- [ ] 2 browsers mở → Cả 2 cập nhật
- [ ] Disconnect → Auto reconnect

---

### TASK-056: Web Push Service Worker & Subscriptions
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn nhận thông báo đẩy từ browser khi có khách mới.

**Description:**
Implement Web Push API với Service Worker.

**Acceptance Criteria:**
- [ ] `webpush` gem hoặc `web-push` gem
- [ ] VAPID keys generation & storage
- [ ] Service Worker: `serviceworker.js`
- [ ] Permission request flow (UI)
- [ ] PushSubscription model (user_id, endpoint, keys)
- [ ] API: Subscribe/Unsubscribe endpoints

**Technical Details:**
```ruby
# Model
class PushSubscription < ApplicationRecord
  belongs_to :user
  encrypts :auth_key, :p256dh_key
end

# Gửi từ job
Webpush.payload_send(
  message: JSON.generate({ title: "Khách mới", body: contact.full_name }),
  endpoint: subscription.endpoint,
  p256dh: subscription.p256dh_key,
  auth: subscription.auth_key,
  vapid: { subject: "mailto:admin@ankhang.vn", ... }
)
```

**Test Cases:**
- [ ] User grant permission → Subscription saved
- [ ] Browser closed → Push vẫn nhận được
- [ ] Click notification → Redirect to contact

---

## 📊 Sprint 3 Summary

| Priority | Count |
|----------|-------|
| 🔴 Critical | 3 |
| 🟡 High | 8 |

**Total Story Points:** ~56

**New Tasks Added (2026-01-29):**
| Task | Description | Story Points |
|------|-------------|--------------|
| TASK-054 | Solid Queue Scheduled Jobs | 5 |
| TASK-055 | WebSocket Realtime Updates | 5 |
| TASK-056 | Web Push Service Worker | 5 |

**Dependencies:**
- Sprint 2 completed (Contact model, Dashboard UI working)
- Solid Queue hoặc Sidekiq running for background jobs
- Redis for ActionCable

**Success Criteria:**
- [x] Sale có thể Pick contact với rules check ✅
- [x] Contact status flow hoạt động đúng ✅
- [x] Admin có thể cấu hình Smart Routing ✅
- [ ] Scheduled jobs chính xác đến giây
- [ ] Real-time updates hoạt động
- [ ] Web Push notifications hoạt động

---

## 📝 Changelog

| Date | Task | Status | Notes |
|------|------|--------|-------|
| 2026-01-28 | TASK-023 | ✅ | Contact detail + Timeline implemented |
| 2026-01-28 | TASK-051 | ✅ | StatusMachine concern completed |
| 2026-01-29 | TASK-022 | ✅ | Core pick mechanism with DB locking |
| 2026-01-29 | TASK-022b | ✅ | Pick Rules Engine with service_type config |
| 2026-01-29 | TASK-053 | ✅ | Smart Routing Config (Admin Settings + ServiceType) |
| 2026-01-29 | TASK-054 | 📋 Created | Solid Queue scheduled jobs spec |
| 2026-01-29 | TASK-055 | 📋 Created | WebSocket realtime updates spec |
| 2026-01-29 | TASK-056 | 📋 Created | Web Push Service Worker spec |
