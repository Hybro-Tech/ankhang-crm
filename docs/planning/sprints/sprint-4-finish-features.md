# Sprint 4: Feature Finish (Notifications & Dashboard)

> **Duration**: Week 8-9 (10/03 - 23/03)
> **Focus**: Multi-channel Notifications, Products, Dashboard, Audit Logs
> **Total Tasks**: 11

---

## Epic: Notification Engine

### TASK-031: Xây dựng Notification Rules Engine
| Field | Value |
|-------|-------|
| **Epic** | Notification Engine |
| **Story Points** | 8 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn tạo rules để tự động gửi thông báo khi có events.

**Description:**
Engine xử lý notification rules theo SRS Section 4.9.

**Acceptance Criteria:**
- [ ] `notification_rules` table: name, trigger_event, conditions (JSON), channels, template, enabled
- [ ] Trigger events: contact.created, contact.picked, contact.status_changed, deal.created
- [ ] Conditions: filter by role, team, etc.
- [ ] Channels: web_push, email, zalo
- [ ] Template với placeholders ({{contact.name}}, etc.)
- [ ] Rule builder UI

**Test Cases:**
- [ ] Create rule → trigger event fires → notification sent
- [ ] Disabled rule → không trigger
- [ ] Condition not met → không gửi

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
> Là Sale, tôi muốn nhận push notification khi có contact mới.

**Acceptance Criteria:**
- [ ] Service worker registration
- [ ] Push subscription management (save to DB)
- [ ] Send to 100-200 users trong < 5 giây (SRS requirement)
- [ ] Notification content: title, body, icon, click action
- [ ] Sidekiq job cho batch sending

**Test Cases:**
- [ ] User grants permission → subscription saved
- [ ] Contact created → all Sales receive push
- [ ] Click notification → redirect to contact

---

### TASK-033: Thông báo qua Email
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là User, tôi muốn nhận email khi có sự kiện quan trọng.

**Acceptance Criteria:**
- [ ] ActionMailer setup với SendGrid/SMTP
- [ ] Email templates (HTML) cho các events
- [ ] Async sending via Sidekiq
- [ ] Unsubscribe option

**Test Cases:**
- [ ] Event fires → email sent
- [ ] Email format correct (HTML rendered)
- [ ] Unsubscribed user → không nhận email

---

### TASK-034: Tích hợp Zalo OA
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 8 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là CSKH, tôi muốn gửi tin Zalo ZNS cho khách hàng.

**Description:**
Integration với Zalo OA API theo SRS Section 4.12.4.

**Acceptance Criteria:**
- [ ] Zalo OA API client (OAuth 2.0)
- [ ] Token refresh mechanism
- [ ] ZNS template management (store template IDs)
- [ ] Send ZNS với dynamic data
- [ ] Zalo composer UI (CSKH page)
- [ ] Rate limiting handling
- [ ] Error handling + retry

**Test Cases:**
- [ ] Send ZNS → delivered
- [ ] Invalid phone → error logged
- [ ] Rate limited → retry via Sidekiq

---

### TASK-035: Cập nhật UI Real-time
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn thấy contact mới xuất hiện real-time mà không cần refresh.

**Acceptance Criteria:**
- [ ] ActionCable setup
- [ ] Turbo Streams subscription cho contacts channel
- [ ] Broadcast khi contact.created
- [ ] Broadcast khi contact.picked (update UI cho others)
- [ ] Connection status indicator

**Test Cases:**
- [ ] Contact created → appears real-time
- [ ] Contact picked → button disappears for others
- [ ] Disconnect → reconnect automatically

---

### TASK-036: Giao diện Cài đặt Thông báo
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 3 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn quản lý notification rules qua UI.

**Acceptance Criteria:**
- [ ] List rules với enable/disable toggle
- [ ] Create/Edit rule form
- [ ] Test send button
- [ ] View send history

**Test Cases:**
- [ ] Toggle disable → rule không fire
- [ ] Test send → notification received

---

## Epic: Dashboard

### TASK-037: Thẻ KPI trên Dashboard
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 3 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn xem các KPI quan trọng ngay khi vào dashboard.

**Acceptance Criteria:**
- [ ] Tổng Contacts
- [ ] Contacts mới (tuần này)
- [ ] Số deals chốt
- [ ] Tỷ lệ chốt (%)
- [ ] Tổng doanh thu
- [ ] Date range filter

**Test Cases:**
- [ ] KPIs calculated correctly
- [ ] Filter by date → numbers update
- [ ] Performance < 2s load

---

### TASK-038: Biểu đồ Dashboard
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 5 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn xem biểu đồ để hiểu xu hướng.

**Acceptance Criteria:**
- [ ] Pie/Donut chart: Contact status distribution
- [ ] Line chart: Contacts trend (by day/week/month)
- [ ] Bar chart: Sales comparison
- [ ] Bar chart: Revenue by team
- [ ] Chart library: Chart.js hoặc ApexCharts

**Test Cases:**
- [ ] Charts render correctly
- [ ] Hover shows values
- [ ] Filter updates charts

---

### TASK-039: Bảng Top Performers
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 2 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn xem ai là top performers.

**Acceptance Criteria:**
- [ ] Table: Name, Số KH picked, Số deals, Doanh thu
- [ ] Sortable columns
- [ ] Top 10 mặc định

**Test Cases:**
- [ ] Data accurate
- [ ] Sort by revenue works

---

## Epic: Audit Logs

### TASK-040: Xem Activity Logs
| Field | Value |
|-------|-------|
| **Epic** | Audit Logs |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn xem tất cả hoạt động trong hệ thống.

**Acceptance Criteria:**
- [ ] List logs với pagination
- [ ] Filter by: user, action, date range, entity type
- [ ] Search bằng keyword
- [ ] Display: timestamp, user, action, entity, IP
- [ ] Diff view (before/after JSON)

**Test Cases:**
- [ ] All actions logged
- [ ] Filter works
- [ ] Diff view shows changes

---

### TASK-041: Trang Báo cáo
| Field | Value |
|-------|-------|
| **Epic** | Reports |
| **Story Points** | 3 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn xem reports chi tiết hơn dashboard.

**Acceptance Criteria:**
- [ ] Revenue by period
- [ ] Conversion funnel
- [ ] Team performance comparison
- [ ] Export button (Phase 2)

---

## 📊 Sprint 4 Summary

| Priority | Count |
|----------|-------|
| 🟡 High | 6 |
| 🟢 Medium | 5 |

**Total Story Points:** ~50

**Dependencies:**
- Sprint 3 completed
- Sidekiq running
- Zalo OA credentials configured
