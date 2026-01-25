# Sprint 1: Foundation (Week 1-2)

> **Duration**: Week 1-2  
> **Focus**: Project Setup, Database, Authentication, Authorization  
> **Total Tasks**: 16

---

## Epic: Preparation & Documentation (Completed)

### TASK-000-A: Tài liệu dự án & Lập kế hoạch
| Field | Value |
|-------|-------|
| **Epic** | Preparation |
| **Story Points** | 5 |
| **Priority** | 🟢 Done |
| **Assignee** | |
| **Status** | Done |

**User Story:**
> Là PM/Developer, tôi cần chuẩn bị đầy đủ tài liệu để thống nhất với khách hàng.

**Acceptance Criteria:**
- [x] SRS Specification (v1.0)
- [x] Implementation Plan & Timeline
- [x] Backlog & Sprint Planning
- [x] Client Meeting Prep checkist

---

### TASK-000-B: Thiết kế Wireframes & Mockups HTML
| Field | Value |
|-------|-------|
| **Epic** | Preparation |
| **Story Points** | 8 |
| **Priority** | 🟢 Done |
| **Assignee** | |
| **Status** | Done |

**User Story:**
> Là Designer, tôi cần tạo bộ Mockup HTML tĩnh để demo luồng đi cho khách hàng.

**Acceptance Criteria:**
- [x] Login Page
- [x] Dashboard Layout
- [x] Contact List & Detail
- [x] Roles & Permission Matrix
- [x] Wireframes Validation

---

## Epic: Project Setup

### TASK-001: Cài đặt Rails & Docker
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Done |

**User Story:**
> Là Developer, tôi muốn khởi tạo project Rails chạy ngay trên Docker để không cần cài Ruby/MySQL trên máy local.

**Description:**
Khởi tạo Rails 7.1+ project trực tiếp qua Docker Compose.

**Acceptance Criteria:**
- [x] `docker-compose.yml` (App, DB, Redis)
- [x] `Dockerfile` optimized cho Rails 7.1
- [x] `rails new` execute qua container
- [x] MySQL 8 + Redis configuration
- [x] Tailwind + Hotwire pre-configured

**Test Cases:**
- [x] `docker-compose up` → Rails welcome page localhost:3000
- [x] Connect Database thành công
- [x] Code changes hot-reload works

---

### TASK-003: Cài đặt Gems cốt lõi
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 2 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Done |

**User Story:**
> Là Developer, tôi muốn có đầy đủ gems cần thiết để phát triển.

**Acceptance Criteria:**
- [x] `devise` - Authentication
- [x] `cancancan` - Authorization
- [x] `sidekiq` - Background jobs
- [x] `kaminari` - Pagination
- [x] `rspec-rails`, `factory_bot_rails` - Testing
- [x] `rubocop-rails` - Linting
- [x] `bullet` - N+1 detection

**Test Cases:**
- [x] `bundle install` thành công
- [x] Tất cả gems load được trong `rails c`

---

### TASK-004: CI/CD Pipeline
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Done |

**User Story:**
> Là Developer, tôi muốn có CI chạy tests tự động khi push code.

**Acceptance Criteria:**
- [x] `.github/workflows/ci.yml`
- [x] Run RSpec tests
- [x] Run RuboCop
- [x] MySQL service trong CI

**Test Cases:**
- [x] Push commit → CI triggered
- [x] CI pass khi tests pass
- [x] CI fail khi có lint error

---

## Epic: Database Schema

### TASK-005: Thiết kế ERD Diagram
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Done |

**User Story:**
> Là Architect, tôi muốn có ERD diagram để team hiểu database structure.

**Acceptance Criteria:**
- [x] ERD diagram (PNG/SVG)
- [x] Users, Roles, Permissions tables
- [x] Teams, Contacts, Deals tables
- [x] Products, Coupons tables
- [x] ActivityLogs table
- [x] All relationships defined

**Test Cases:**
- [x] Review với team
- [x] Không có circular dependencies

---

### TASK-006: Xây dựng Layout UI cơ bản
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là Developer, tôi muốn có layout base để tất cả các trang đều có giao diện nhất quán.

**Description:**
Xây dựng khung layout chính cho ứng dụng, bao gồm sidebar, header, footer và các base components.

**Acceptance Criteria:**
- [x] Application layout với sidebar, header, main content area
- [x] Tailwind theme setup (colors theo brand An Khang)
- [x] Base components: Button, Input, Card, Table, Alert, Modal
- [x] Responsive navigation (mobile sidebar toggle)
- [x] Flash messages styling (success, error, warning)
- [x] Typography system (headings, body text)
- [x] Dark mode ready (optional)

**Test Cases:**
- [x] Layout render đúng trên desktop (>1024px)
- [x] Layout responsive trên mobile (<768px)
- [x] Sidebar toggle hoạt động trên mobile
- [x] All base components render đúng

**Related:** Wireframes trong `docs/ui-design/wireframes/`

---

### TASK-007: Migration Users & Authentication
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là Developer, tôi muốn có bảng users để implement authentication.

**Description:**
Tạo migrations cho Devise users và thông tin nhân viên.

**Acceptance Criteria:**
- [x] `users` table với Devise columns
- [x] Extra fields: name, phone, status, team_id
- [x] Indexes trên email, team_id

**Test Cases:**
- [x] `rails db:migrate` thành công
- [x] User.create với valid data OK

---

### TASK-008: Migration RBAC (Roles & Permissions)
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là Developer, tôi muốn có bảng roles/permissions để implement RBAC động.

**Description:**
Tạo migrations cho dynamic permissions theo SRS PERM-001→007.

**Acceptance Criteria:**
- [x] `roles` table (name, description, is_system)
- [x] `permissions` table (subject, action, description)
- [x] `role_permissions` join table
- [x] `user_roles` join table
- [x] `user_permissions` override table (granted boolean)

**Test Cases:**
- [x] Seed 4 default roles thành công
- [x] Seed permissions list thành công

**Related:** `docs/tinh-nang/phan-quyen/requirements.md`

---

### TASK-009: Migration bảng Teams
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 2 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là Developer, tôi muốn có bảng teams để nhóm nhân viên.

**Acceptance Criteria:**
- [x] `teams` table (name, description, manager_id, region)
- [x] FK từ users.team_id → teams.id

**Test Cases:**
- [x] Team với users association hoạt động

---

### TASK-010: Seed Data - Roles & Permissions
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 2 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là Admin, tôi muốn có 4 roles mặc định sẵn khi deploy.

**Description:**
Seed Super Admin, Tổng Đài, Sale, CSKH với permissions theo SRS.

**Acceptance Criteria:**
- [x] 4 system roles seeded
- [x] All permissions seeded (~15 items)
- [x] Role-permission mappings theo SRS Section 3.2

**Test Cases:**
- [x] `rails db:seed` thành công
- [x] Role.find_by(name: 'Super Admin') có tất cả permissions

**Related:** SRS Section 3.2, Section 4.2

---

## Epic: Authentication

### TASK-011: Cấu hình Devise Authentication
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là User, tôi muốn đăng nhập vào hệ thống bằng username/password.

**Description:**
Setup Devise theo SRS AUTH-001→006.

**Acceptance Criteria:**
- [x] Login với username/email
- [x] Password bcrypt cost 12
- [x] Session timeout 3 ngày
- [x] Remember me 30 ngày
- [x] Lock sau 5 lần fail (15 phút)

**Test Cases:**
- [x] Login với valid credentials → success
- [x] Login với wrong password → error
- [x] 5 wrong attempts → account locked

**Related:** SRS Section 4.1

---

### TASK-012: Giao diện trang Đăng nhập
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 2 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là User, tôi muốn có trang login đẹp và dễ dùng.

**Description:**
Implement login page theo wireframe `index.html`.

**Acceptance Criteria:**
- [x] Form login (username, password, remember me)
- [x] Link "Quên mật khẩu"
- [x] Error message khi login fail
- [x] Responsive design

**Test Cases:**
- [x] UI giống wireframe
- [x] Form submit qua Turbo

**Related:** Wireframe `docs/ui-design/wireframes/index.html`

---

### TASK-013: Luồng Quên mật khẩu
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là User, tôi muốn reset password nếu quên.

**Description:**
Implement forgot password theo SRS AUTH-003.

**Acceptance Criteria:**
- [x] Form nhập email
- [x] Gửi email với reset link
- [x] Link hết hạn sau 1 giờ
- [x] Form đổi password mới

**Test Cases:**
- [x] Request reset → email sent
- [x] Click link → form hiển thị
- [x] Submit new password → login OK
- [x] Click expired link → error

**Related:** Wireframe `docs/ui-design/wireframes/forgot_password.html`

---

### TASK-014: Ghi log Đăng nhập/Đăng xuất
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 2 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | ✅ Done |

**User Story:**
> Là Admin, tôi muốn xem log ai đã login/logout.

**Description:**
Log auth events vào ActivityLog.

**Acceptance Criteria:**
- [x] Log login success
- [x] Log login failed (username + IP)
- [x] Log logout
- [x] Log password change

**Test Cases:**
- [x] Login → ActivityLog created với action 'login'
- [x] Log chứa IP address và user_agent

---

## Epic: Authorization (RBAC)

### TASK-015: Xây dựng Ability Class (CanCanCan)
| Field | Value |
|-------|-------|
| **Epic** | Authorization |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là System, tôi muốn load permissions từ DB để check quyền động.

**Description:**
Implement Ability class load từ roles + user overrides.

**Acceptance Criteria:**
- [ ] Load permissions từ user.roles
- [ ] Apply user_permissions overrides
- [ ] Super Admin có tất cả quyền
- [ ] Cache ability nếu cần

**Test Cases:**
- [ ] User với role Sale có thể :pick Contact
- [ ] User bị deny override không thể access
- [ ] Super Admin can :manage, :all

**Related:** `.agent/skills/cancancan-rbac/SKILL.md`

---

### TASK-016: Giao diện Ma trận Phân quyền
| Field | Value |
|-------|-------|
| **Epic** | Authorization |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn xem và chỉnh sửa permissions của mỗi role qua UI.

**Description:**
Trang quản lý roles với checkbox matrix.

**Acceptance Criteria:**
- [ ] List all roles
- [ ] Checkbox matrix (roles × permissions)
- [ ] Không cho xóa system roles
- [ ] Clone role functionality

**Test Cases:**
- [ ] Check/uncheck permission → save OK
- [ ] Clone role → new role với same permissions
- [ ] Delete system role → error

**Related:** Wireframe `docs/ui-design/wireframes/roles.html`

---

## 📊 Sprint 1 Summary

| Priority | Count |
|----------|-------|
| 🔴 Critical | 12 |
| 🟡 High | 4 |

**Total Story Points:** ~53
