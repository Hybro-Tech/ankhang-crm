# Sprint 4: Feature Finish (ZNS & Dashboard)

> **Duration**: 10/03/2026 - 23/03/2026 (2 tuần)  
> **Focus**: ZNS Integration, Email, Dashboard & Reports, Audit Logs  
> **Goal**: Hoàn thành 100% Feature Development  
> **Total Tasks**: 9

---

## Epic: ZNS (Zalo Notification Service)

### TASK-034: Tích hợp Zalo OA
| Field | Value |
|-------|-------|
| **Epic** | ZNS |
| **Story Points** | 8 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là CSKH, tôi muốn gửi tin Zalo ZNS cho khách hàng.

**Description:**
Integration với Zalo OA API theo SRS v2 Section 7.

**Acceptance Criteria:**
- [ ] Zalo OA API client (OAuth 2.0)
- [ ] Token refresh mechanism (auto refresh before expiry)
- [ ] ZNS template management (store template IDs from Zalo)
- [ ] Send ZNS với dynamic data
- [ ] Rate limiting handling
- [ ] Error handling + retry via Sidekiq

**Test Cases:**
- [ ] Send ZNS → Delivered
- [ ] Invalid phone → Error logged
- [ ] Rate limited → Retry via Sidekiq

**Related:** SRS v2 Section 7

---

### TASK-054: Quản lý Mẫu ZNS (CRUD)
| Field | Value |
|-------|-------|
| **Epic** | ZNS |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn quản lý các mẫu tin nhắn ZNS.

**Description:**
CRUD cho ZNS templates theo SRS v2 Section 7.3.

**Acceptance Criteria:**
- [ ] `zns_templates` table: name, zalo_template_id, preview_content, variables (JSON), status
- [ ] List templates với status filter
- [ ] Create/Edit form:
  - [ ] Tên mẫu
  - [ ] Mã Zalo (Template ID từ Zalo OA)
  - [ ] Nội dung preview
  - [ ] Biến động (placeholders): `{ten_kh}`, `{so_dien_thoai}`
- [ ] Activate/Deactivate

**Test Cases:**
- [ ] Create template → Appears in list
- [ ] Deactivate → Không hiện trong send form

---

### TASK-055: Giao diện Gửi ZNS (CSKH)
| Field | Value |
|-------|-------|
| **Epic** | ZNS |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là CSKH, tôi muốn gửi tin ZNS cho khách hàng một cách dễ dàng.

**Description:**
UI gửi ZNS thủ công theo SRS v2 Section 7.1.

**Acceptance Criteria:**
- [ ] Chọn 1 hoặc nhiều khách hàng (checkbox list)
- [ ] Filter KH: Theo trạng thái, team, ngày tạo
- [ ] Chọn mẫu ZNS từ dropdown
- [ ] Preview tin nhắn với data thực
- [ ] Confirm trước khi gửi
- [ ] Hiển thị kết quả: Thành công / Thất bại

**Test Cases:**
- [ ] Select 5 KH → Preview → Send → 5 ZNS sent
- [ ] KH không có SĐT → Warning

---

### TASK-056: Lịch sử Gửi ZNS
| Field | Value |
|-------|-------|
| **Epic** | ZNS |
| **Story Points** | 3 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là CSKH/Admin, tôi muốn xem lịch sử gửi ZNS.

**Acceptance Criteria:**
- [ ] `zns_logs` table: contact_id, template_id, sent_by_id, status, error_message, sent_at
- [ ] List view với filter: by contact, by date range, by status
- [ ] Detail view: Nội dung đã gửi

**Test Cases:**
- [ ] Send ZNS → Log created
- [ ] Filter by date → Correct results

---

## Epic: Email Notifications

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
- [ ] Email templates (HTML) cho các events:
  - [ ] Contact assigned to you
  - [ ] Reminder: Lịch hẹn sắp tới
  - [ ] Admin: Daily summary
- [ ] Async sending via Sidekiq
- [ ] Unsubscribe option (optional)

**Test Cases:**
- [ ] Event fires → Email sent
- [ ] Email format correct (HTML rendered)

---

## Epic: Dashboard & Reports

### TASK-037: Thẻ KPI trên Dashboard (Admin)
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
- [ ] KPI Cards:
  - [ ] Tổng Contacts
  - [ ] Contacts mới (tuần này)
  - [ ] Số contacts đã chốt
  - [ ] Tỷ lệ chốt (%)
- [ ] Date range filter
- [ ] Performance < 2s load

**Test Cases:**
- [ ] KPIs calculated correctly
- [ ] Filter by date → Numbers update

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
- [ ] Bar chart: Sales comparison (số contact picked)
- [ ] Chart library: Chart.js hoặc ApexCharts
- [ ] Responsive trên mobile

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
- [ ] Table: Name, Số KH picked, Số KH chốt, Tỷ lệ
- [ ] Sortable columns
- [ ] Top 10 mặc định
- [ ] Filter by team, date range

**Test Cases:**
- [ ] Data accurate
- [ ] Sort by picked count works

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
- [ ] Diff view (before/after JSON) cho update actions

**Test Cases:**
- [ ] All actions logged
- [ ] Filter works
- [ ] Diff view shows changes

**Related:** SRS v2 Section 9

---

## 📊 Sprint 4 Summary

| Priority | Count |
|----------|-------|
| 🔴 Critical | 1 |
| 🟡 High | 4 |
| 🟢 Medium | 4 |

**Total Story Points:** ~37

**Dependencies:**
- Sprint 3 completed (Contacts + Real-time working)
- Sidekiq running
- Zalo OA credentials configured

**Success Criteria:**
- [ ] CSKH có thể gửi ZNS cho khách hàng
- [ ] Email notifications hoạt động
- [ ] Admin Dashboard với KPI và Charts
- [ ] Activity Logs hoàn chỉnh
- [ ] **100% Feature Development hoàn thành**
