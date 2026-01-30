# Backlog Ưu Tiên - Sprint 3 & Cải Tiến

> **Ngày cập nhật**: 30/01/2026  
> **Sprint hiện tại**: Sprint 3 (23/02 - 09/03/2026)  
> **Stack**: Full Solid (Queue + Cable + Cache) - No Redis

---

## ✅ ĐÃ HOÀN THÀNH HÔM NAY

| # | Task/Item | Mô tả | Status |
|---|-----------|-------|--------|
| 1 | Solid Cable | Thay thế Redis ActionCable | ✅ Done |
| 2 | Remove Redis | Xoá redis gem + container | ✅ Done |
| 3 | Docker Rebuild | Rebuild image với solid_cable gem | ✅ Done |
| 4 | Migrations | Solid Cable tables created | ✅ Done |
| 5 | **TASK-035** | ActionCable + Turbo Streams Real-time | ✅ Done |

---

## 🎯 DANH SÁCH ƯU TIÊN (Còn lại)

### ⚡ CRITICAL (Phải làm trước)

| # | Task/Item | Loại | Mô tả | Effort |
|---|-----------|------|-------|--------|
| **1** | TASK-054 | Sprint 3 | Solid Queue Scheduled Jobs (Smart Routing) | 5 SP |
| **2** | TASK-055 | Sprint 3 | WebSocket Realtime Updates | 5 SP |

---

### 🟡 HIGH (Quan trọng)

| # | Task/Item | Loại | Mô tả | Effort |
|---|-----------|------|-------|--------|
| **4** | VAPID Keys | Infra | Generate Web Push VAPID keys | 1h |
| **5** | TASK-032 | Sprint 3 | Thông báo Web Push | 5 SP |
| **6** | TASK-056 | Sprint 3 | Web Push Service Worker & Subscriptions | 5 SP |
| **7** | TASK-052 | Sprint 3 | Admin Re-assign Contact (Approval Workflow) | 8 SP |
| **8** | Annotate Models | Improve | Chạy `annotate --models` để document schema | 30m |
| **9** | Rubocop Cleanup | Improve | Chạy `rubocop -A` toàn project | 1h |

---

### 🟢 MEDIUM (Nên làm)

| # | Task/Item | Loại | Mô tả | Effort |
|---|-----------|------|-------|--------|
| **10** | Test Coverage | Improve | RSpec integration tests cho Pick flow | 4h |
| **11** | Authorization Specs | Improve | Fix authorization tests cho RolesController | 2h |
| **12** | Race Condition Tests | Improve | Tests cho concurrent pick scenarios | 3h |
| **13** | N+1 Review | Improve | Review queries với Bullet gem | 2h |
| **14** | CODEBASE.md | Docs | Cập nhật với Contacts, ServiceTypes, Interactions | 2h |
| **15** | API Docs | Docs | Document PickEligibilityService, SmartRoutingService | 2h |

---

### 🔵 LOW (Khi có thời gian)

| # | Task/Item | Loại | Mô tả | Effort |
|---|-----------|------|-------|--------|
| **16** | TASK-047 | Deferred | Cronjob tạo lịch nghỉ cho năm mới | 3h |
| **17** | TASK-048 | Deferred | Integrate Saturday Schedule với Smart Routing | 4h |
| **18** | I18n Completion | Tech Debt | Hoàn thiện translations (~30% hardcoded) | 4h |
| **19** | CSS Cleanup | Tech Debt | Consolidate duplicate Tailwind classes | 2h |
| **20** | ViewComponent | Tech Debt | Migrate partials phức tạp sang ViewComponent | 8h |
| **21** | Stimulus Refactor | Tech Debt | Tách Stimulus controllers lớn | 4h |

---

## ✅ Infrastructure Status (Full Solid Stack)

| Component | Status | Notes |
|-----------|--------|-------|
| **MySQL** | ✅ Running | Port 3306 |
| **Solid Queue** | ✅ Running | Worker container |
| **Solid Cache** | ✅ Ready | Database-backed |
| **Solid Cable** | ✅ Ready | Database-backed WebSocket |
| **Redis** | ❌ Removed | Không cần nữa |

---

## 🔄 Migrate lên Redis (nếu cần sau này)

Chỉ cần 3 bước:
1. Thêm `gem "redis"` vào Gemfile
2. Đổi `cable.yml` adapter thành `redis`
3. Thêm Redis container vào docker-compose

**Thời gian ước tính: 30 phút**
