# Sprint 4: Feature Finish (Dashboard, Logs, Email)

> **Duration**: 03/02/2026 - 16/02/2026 (2 tuần)  
> **Focus**: Dashboard & Reports, Activity Logs, Email Notifications  
> **Goal**: Hoàn thành 100% Feature Development (trừ ZNS - deferred)  
> **Total Tasks**: 5 (+ ZNS khi có thông tin)
> 
> **⚠️ LƯU Ý**: ZNS tasks đã được defer do chưa có thông tin credentials từ Zalo OA.  
> Xem chi tiết: `docs/planning/remaining-tasks.md`

---

## ⚡ PHASE A: LÀM NGAY (Available Now)

---

## Epic: Dashboard & Reports

### TASK-037: Thẻ KPI trên Dashboard (Admin)
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 3 |
| **Priority** | � High |
| **Assignee** | |
| **Status** | 🔵 Ready |

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

**Dependencies:** ✅ None - Backend logic có sẵn trong `DashboardController#build_admin_kpi`

---

### TASK-038: Biểu đồ Dashboard
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | 🔵 Ready |

**User Story:**
> Là Admin, tôi muốn xem biểu đồ để hiểu xu hướng.

**Acceptance Criteria:**
- [ ] Pie/Donut chart: Contact status distribution
- [ ] Line chart: Contacts trend (by day/week/month)
- [ ] Bar chart: Sales comparison (số contact picked)
- [ ] Chart library: Chartkick (đã cài) hoặc ApexCharts
- [ ] Responsive trên mobile

**Test Cases:**
- [ ] Charts render correctly
- [ ] Hover shows values
- [ ] Filter updates charts

**Dependencies:** ✅ None - `build_admin_chart_data` đã có

---

### TASK-039: Bảng Top Performers
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 2 |
| **Priority** | � Medium |
| **Assignee** | |
| **Status** | 🔵 Ready |

**User Story:**
> Là Admin, tôi muốn xem ai là top performers.

**Acceptance Criteria:**
- [ ] Table: Name, Số KH picked, Số KH chốt, Tỷ lệ
- [ ] Sortable columns
- [ ] Top 10 mặc định
- [ ] Filter by team, date range

**Test Cases:**
- [ ] Data accurate (không còn mock data)
- [ ] Sort by picked count works

**Dependencies:** ✅ None - Cần convert `mock_top_performers` → real query

---

## Epic: Audit Logs

### TASK-040: Xem Activity Logs
| Field | Value |
|-------|-------|
| **Epic** | Audit Logs |
| **Story Points** | 5 |
| **Priority** | � High |
| **Assignee** | |
| **Status** | 🔵 Ready |

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

**Dependencies:** ✅ None - `ActivityLog` model đã hoàn chỉnh

**Related:** SRS v2 Section 9, Wireframe `logs.html`

---

## Epic: Email Notifications

### TASK-033: Thông báo qua Email
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | 🔵 Ready |

**User Story:**
> Là User, tôi muốn nhận email khi có sự kiện quan trọng.

**Acceptance Criteria:**
- [ ] ActionMailer setup với SendGrid/SMTP
- [ ] Email templates (HTML) cho các events:
  - [ ] Contact assigned to you
  - [ ] Reminder: Lịch hẹn sắp tới
  - [ ] Admin: Daily summary
- [ ] Async sending via Solid Queue
- [ ] Unsubscribe option (optional)

**Test Cases:**
- [ ] Event fires → Email sent
- [ ] Email format correct (HTML rendered)

**Dependencies:** ✅ None - `ApplicationMailer` và Solid Queue đã có

---

## ⏸️ PHASE B: CHỜ THÔNG TIN (ZNS Deferred)

> **Lý do:** Chưa có thông tin credentials từ Zalo OA  
> **Khi có thông tin:** Sẽ bổ sung vào sprint hoặc tạo sprint riêng

### TASK-034: Tích hợp Zalo OA (⏸️ WAITING)
| Field | Value |
|-------|-------|
| **Epic** | ZNS |
| **Story Points** | 8 |
| **Priority** | � Critical |
| **Status** | ⏸️ Waiting for Credentials |

**Thông tin cần:**
- [ ] Zalo OA App ID & Secret Key
- [ ] Zalo OA Refresh Token
- [ ] Danh sách Template IDs đã được duyệt
- [ ] Quy tắc gửi ZNS (`docs/CÁC RULES ZNS DỰ KIẾN.docx`)

---

### ZNS Templates CRUD (⏸️ WAITING)
- Quản lý Mẫu ZNS
- **Status:** ⏸️ Waiting - depends on TASK-034

---

### ZNS Send UI (⏸️ WAITING)
- Giao diện Gửi ZNS cho CSKH
- **Status:** ⏸️ Waiting - depends on TASK-034

---

### ZNS History (⏸️ WAITING)
- Lịch sử Gửi ZNS
- **Status:** ⏸️ Waiting - depends on TASK-034

---

## 📊 Sprint 4 Summary

| Priority | Count (Phase A) | Count (Phase B - Deferred) |
|----------|-----------------|---------------------------|
| 🔴 Critical | 0 | 1 |
| 🟡 High | 4 | 0 |
| 🟢 Medium | 1 | 3 |

**Phase A Total Story Points:** ~18  
**Phase B (Deferred) Story Points:** ~19

**Dependencies:**
- ✅ Sprint 3 completed (Contacts + Real-time working)
- ✅ Solid Queue running
- ⏸️ Zalo OA credentials (for Phase B)

**Success Criteria (Phase A):**
- [ ] Admin Dashboard với KPI và Charts
- [ ] Top Performers với real data
- [ ] Activity Logs UI hoàn chỉnh
- [ ] Email notifications hoạt động

**Timeline:**
```
TUẦN 1 (03/02 - 09/02):
├── TASK-037: KPI Cards Dashboard
├── TASK-038: Charts Dashboard
└── TASK-039: Top Performers

TUẦN 2 (10/02 - 16/02):
├── TASK-040: Activity Logs UI
└── TASK-033: Email Notifications
```
