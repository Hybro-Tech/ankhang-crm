# Backlog Ưu Tiên - Sprint 4 (Cập nhật)

> **Ngày cập nhật**: 01/02/2026  
> **Sprint hiện tại**: Sprint 4 (Bắt đầu 03/02/2026)  
> **Stack**: Full Solid (Queue + Cable + Cache) - No Redis  
> **Thay đổi**: ZNS tasks deferred - chờ thông tin từ Zalo OA

---

## ✅ SPRINT 3 - ĐÃ HOÀN THÀNH (100%)

| # | Task | Mô tả | Status |
|---|------|-------|--------|
| 1 | TASK-022 | Pick Core (DB Locking/Concurrency) | ✅ Done |
| 2 | TASK-022b | Pick Rules Engine (Dynamic Limits) | ✅ Done |
| 3 | TASK-023 | Contact Detail & Care Timeline | ✅ Done |
| 4 | TASK-051 | Status Flow (State Machine) | ✅ Done |
| 5 | TASK-052 | Admin Re-assign/Unassign Workflow | ✅ Done |
| 6 | TASK-053 | Smart Routing Config | ✅ Done |
| 7 | TASK-054 | Solid Queue Polling (0.1s) | ✅ Done |
| 8 | TASK-035 | ActionCable Real-time Engine | ✅ Done |
| 9 | TASK-055 | WebSocket Turbo Streams Sync | ✅ Done |
| 10 | TASK-055b | Connection Status Indicator | ✅ Done |
| 11 | TASK-056/032 | Web Push Infra & UI (VAPID) | ✅ Done |
| 12 | Solid Dashboards | Custom Queue/Cache/Cable Monitoring | ✅ Done |
| 13 | UI-SYNC | Real-time notification click handling | ✅ Done |
| 14 | KPI-SYNC | Real-time KPI header sync | ✅ Done |

---

## 🎯 SPRINT 4 - DANH SÁCH ƯU TIÊN (Sắp xếp lại)

### ⚡ PHASE A: LÀM NGAY (Available Now)

#### A1. Dashboard & Reports (Tuần 1)

| # | Task | Mô tả | Effort | Status |
|---|------|-------|--------|--------|
| 1 | **TASK-037** | KPI Cards trên Admin Dashboard | 3 SP | 🔵 Ready |
| 2 | **TASK-038** | Biểu đồ Dashboard (Charts) | 5 SP | 🔵 Ready |
| 3 | **TASK-039** | Bảng Top Performers (Real Data) | 2 SP | 🔵 Ready |

**Dependencies:** ✅ None - Backend logic có sẵn trong `DashboardController`  
**Wireframe:** `docs/ui-design/wireframes/dashboard.html`

---

#### A2. Activity Logs UI (Tuần 1-2)

| # | Task | Mô tả | Effort | Status |
|---|------|-------|--------|--------|
| 4 | **TASK-040** | Activity Logs Viewer (List, Filter, Diff) | 5 SP | 🔵 Ready |

**Dependencies:** ✅ None - `ActivityLog` model đã hoàn chỉnh  
**Wireframe:** `docs/ui-design/wireframes/logs.html`

---

#### A3. Email Notifications (Tuần 2)

| # | Task | Mô tả | Effort | Status |
|---|------|-------|--------|--------|
| 5 | **TASK-033** | Email Notifications (ActionMailer + Solid Queue) | 3 SP | 🔵 Ready |

**Scope:**
- Contact assigned notification
- Reminder: Lịch hẹn sắp tới
- Admin: Daily summary (optional)

**Dependencies:** ✅ None - `ApplicationMailer` và Solid Queue đã có

---

#### A4. Tech Debt Quick Wins (Tuần 1-2)

| # | Item | Mô tả | Effort | Status |
|---|------|-------|--------|--------|
| 6 | Annotate Refresh | `annotate --models` (update annotations) | 30m | 🔵 Ready |
| 7 | N+1 Audit | Bullet gem optimization | 2h | 🔵 Ready |
| 8 | I18n Audit | Identify remaining hardcoded strings | 1h | 🔵 Ready |

---

### ⏸️ PHASE B: CHỜ THÔNG TIN (ZNS Deferred)

| # | Task | Mô tả | Status | Chờ |
|---|------|-------|--------|-----|
| - | TASK-034 | Tích hợp Zalo OA API | ⏸️ Waiting | Credentials |
| - | ZNS Templates | Quản lý Mẫu ZNS (CRUD) | ⏸️ Waiting | Template IDs |
| - | ZNS Send UI | Giao diện Gửi ZNS (CSKH) | ⏸️ Waiting | API Ready |
| - | ZNS History | Lịch sử Gửi ZNS | ⏸️ Waiting | API Ready |

**Thông tin cần để bắt đầu:**
- [ ] Zalo OA App ID & Secret Key
- [ ] Zalo OA Refresh Token  
- [ ] Danh sách Template IDs đã được duyệt
- [ ] Quy tắc gửi ZNS (xem `docs/CÁC RULES ZNS DỰ KIẾN.docx`)

---

### 🔔 PHASE C: NOTIFICATION IMPROVEMENTS (Backlog - Future Sprint)

> **Ngày thêm**: 02/02/2026  
> **Nguồn**: Code Review Session

| # | Feature | Mô tả | Effort | Priority |
|---|---------|-------|--------|----------|
| 1 | Delete/Archive | Xóa notifications cũ, archive > 30 ngày | 1h | 🟡 Medium |
| 2 | Filter by Category | Lọc theo Contact/Deal/System/Approval | 30m | 🟡 Medium |
| 3 | Notification Settings | User preferences (bật/tắt loại thông báo) | 2h | 🟢 Low |
| 4 | Web Push | Desktop push notifications với sound | 4h | 🟢 Low |
| 5 | Real-time List Update | Turbo Stream append notification mới vào list | 1h | 🟡 Medium |
| 6 | Bulk Actions | Chọn nhiều để delete/mark as read | 1h | 🟢 Low |

**Total Effort:** ~10 hours

---

## 🔵 SPRINT 5 - PRODUCTION PREP (Sau khi hoàn thành Phase A)

| # | Priority | Task | Mô tả | Effort |
|---|----------|------|-------|--------|
| 1 | 🔴 Critical | TASK-043 | Kiểm tra Bảo mật (Brakeman, OWASP) | 3 SP |
| 2 | 🔴 Critical | TASK-044 | Cài đặt Server Production | 5 SP |
| 3 | 🔴 Critical | TASK-045 | Backup & Monitoring (Sentry, S3) | 3 SP |
| 4 | 🟢 Medium | TASK-046 | Tài liệu & Bàn giao | 3 SP |
| 5 | 🔴 Critical | TASK-042 | UAT & Fixes | 5 SP |
| 6 | 🔴 Critical | **TASK-047** | **Test Coverage: Jobs/Services/Mailers** | 4 SP |

> **TASK-047 Details** (Thêm 02/02/2026):
> - Viết RSpec tests cho tất cả Jobs (đặc biệt `ReassignRequestNotificationJob`)
> - Viết RSpec tests cho tất cả Services chưa có test
> - Viết RSpec tests cho Mailers
> - Mục tiêu: phát hiện bugs như `recipient → user` trước khi deploy

---

## 📅 TIMELINE ĐỀ XUẤT

```
TUẦN 1 (03/02 - 09/02):
├── TASK-037: KPI Cards Dashboard
├── TASK-038: Charts Dashboard  
├── TASK-039: Top Performers
└── Tech Debt (Annotate, N+1 Audit)

TUẦN 2 (10/02 - 16/02):
├── TASK-040: Activity Logs UI
└── TASK-033: Email Notifications

TUẦN 3+ (17/02 onwards):
├── ZNS Integration (khi có thông tin)
└── Sprint 5: Production Prep
```

---

## ✅ Infrastructure Status (Full Solid Stack)

| Component | Status | Notes |
|-----------|--------|-------|
| **MySQL** | ✅ Running | Port 3306 |
| **Solid Queue** | ✅ Running | Worker container |
| **Solid Cache** | ✅ Ready | Database-backed |
| **Solid Cable** | ✅ Ready | Database-backed WebSocket |
| **Redis** | ❌ Removed | Không cần |
| **RSpec** | ✅ 315+ passing | Full coverage |
| **Rubocop** | ✅ 0 offenses | Clean |

---

> **Cập nhật lần cuối:** 01/02/2026  
> **Phê duyệt bởi:** User
