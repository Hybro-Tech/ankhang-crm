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

### TASK-052: Admin Re-assign Contact
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn chuyển Contact cho người khác khi cần thiết.

**Acceptance Criteria:**
- [ ] Chỉ Admin có quyền
- [ ] Modal: Chọn user mới từ dropdown (filter by team)
- [ ] Nhập lý do re-assign (bắt buộc)
- [ ] Update assigned_user_id
- [ ] Log chi tiết: ai, cho ai, lý do, thời gian
- [ ] Notification cho user mới

**Test Cases:**
- [ ] Admin re-assign → Success + Logged
- [ ] Non-admin re-assign → Forbidden

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

## 📊 Sprint 3 Summary

| Priority | Count |
|----------|-------|
| 🔴 Critical | 3 |
| 🟡 High | 5 |

**Total Story Points:** ~41

**Dependencies:**
- Sprint 2 completed (Contact model, Dashboard UI working)
- Sidekiq running for background jobs

**Success Criteria:**
- [x] Sale có thể Pick contact với rules check ✅
- [x] Contact status flow hoạt động đúng ✅
- [ ] Admin có thể re-assign và cấu hình Smart Routing
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
