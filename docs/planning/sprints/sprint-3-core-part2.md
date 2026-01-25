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
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn "pick" contact mới nhưng phải tuân thủ rule của công ty.

**Description:**
Core feature với concurrency handling và dynamic rules checking.

**Acceptance Criteria:**
- [ ] Nút "Nhận khách" chỉ hiện khi đủ điều kiện
- [ ] **Logic Check**:
    - [ ] Cooldown (VD: 5 phút giữa 2 lần pick)
    - [ ] **Dynamic Limit**: Check số lượng đã pick trong ngày theo loại nhu cầu
- [ ] DB Locking (Transaction) - tránh race condition
- [ ] Update Contact: assigned_user_id, status = "Tiềm_năng", picked_at
- [ ] Log activity

**Test Cases:**
- [ ] Pick → Success (Update Assignee, Status)
- [ ] Pick quá giới hạn → Error "Bạn đã nhận đủ số lượng khách loại này trong ngày"
- [ ] 2 users pick cùng lúc → Chỉ 1 thành công

---

### TASK-022b: Pick Rules Engine (Backend)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn cấu hình giới hạn nhận khách cho từng loại dịch vụ.

**Description:**
Extensible rules engine, ban đầu hardcode nhưng sẵn sàng mở rộng.

**Acceptance Criteria:**
- [ ] `pick_rules` table: service_type_id, max_per_day, cooldown_minutes, enabled
- [ ] Seed default rules cho các loại nhu cầu
- [ ] Service: `PickEligibilityService.check(user, contact)` → {eligible: true/false, reason: "..."}
- [ ] Admin UI: Form edit Service Type có input cho max_pick_per_day
- [ ] Code extensible: Có thể thêm conditions mới dễ dàng

**Test Cases:**
- [ ] PickEligibilityService trả về đúng
- [ ] Admin chỉnh limit → Áp dụng ngay

---

### TASK-023: Chi tiết Contact & Lịch sử chăm sóc
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn xem chi tiết và ghi lại lịch sử chăm sóc.

**Acceptance Criteria:**
- [ ] View Detail Contact với tất cả fields
- [ ] Lịch sử trao đổi (Timeline view):
  - [ ] Ngày giờ, Nội dung, Phương thức (Gọi điện/Zalo/Email/Gặp mặt)
  - [ ] Form thêm ghi chú mới
- [ ] Lịch hẹn tiếp theo (datetime picker)
- [ ] Edit Contact info (quyền theo role)

**Test Cases:**
- [ ] Add interaction → Appears in timeline
- [ ] Set lịch hẹn → Hiển thị trên Dashboard

**Related:** SRS v2 Section 5.3

---

### TASK-051: Trạng thái Contact Flow (State Machine)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn chuyển trạng thái Contact theo đúng quy trình công ty.

**Description:**
Implement state machine theo SRS v2 Section 5.2.

**Acceptance Criteria:**
- [ ] State machine: Mới → Tiềm_năng → Đang_tư_vấn → Chốt_Mới/Thất_bại
- [ ] Transition rules:
  - [ ] Mới → Tiềm_năng: Khi Sale nhận
  - [ ] Tiềm_năng → Đang_tư_vấn: Khi Sale bắt đầu tư vấn
  - [ ] Tiềm_năng → Tiềm_năng_cũ: Cronjob đầu tháng
  - [ ] Đang_tư_vấn → Chốt_Mới: Thành công trong tháng
  - [ ] Tiềm_năng_cũ → Chốt_Cũ: Thành công từ tháng trước
  - [ ] Thất_bại → CSKH_L1: Chuyển CSKH
- [ ] UI: Dropdown chọn trạng thái (chỉ hiện valid transitions)
- [ ] Log mỗi lần chuyển trạng thái

**Test Cases:**
- [ ] Valid transition → Success
- [ ] Invalid transition (VD: Mới → Chốt) → Error
- [ ] Log ghi nhận đúng

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
- [ ] Sale có thể Pick contact với rules check
- [ ] Contact status flow hoạt động đúng
- [ ] Admin có thể re-assign và cấu hình Smart Routing
- [ ] Real-time updates hoạt động
- [ ] Web Push notifications hoạt động
