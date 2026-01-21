# 📋 AnKhangCRM - Product Backlog

> **Version 1.0** | Last Updated: 2026-01-21  
> **Format**: Ready for Kanban import (Trello/Jira/Notion)

---

## 📊 Overview

| Sprint | Focus | Duration | Tasks |
|--------|-------|----------|-------|
| Sprint 1 | Foundation | Week 1-2 | 15 |
| Sprint 2 | Core Features (Part 1) | Week 3-4 | 18 |
| Sprint 3 | Core Features (Part 2) | Week 5 | 12 |
| Sprint 4 | Notifications | Week 6 | 10 |
| Sprint 5 | Dashboard & Deploy | Week 7-8 | 12 |

**Story Points Scale**: 1 (trivial) → 2 (easy) → 3 (medium) → 5 (complex) → 8 (very complex)

---

# Sprint 1: Foundation (Week 1-2)

## Epic: Project Setup

### TASK-001: Initialize Rails Project
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có project Rails chuẩn để bắt đầu phát triển.

**Description:**
Khởi tạo Rails 7.1+ project với cấu hình production-ready.

**Acceptance Criteria:**
- [ ] Rails 7.1+ với Ruby 3.2+
- [ ] MySQL adapter configured
- [ ] Hotwire (Turbo + Stimulus) enabled
- [ ] Tailwind CSS setup
- [ ] RSpec configured

**Test Cases:**
- [ ] `rails s` chạy OK tại localhost:3000
- [ ] `rails db:create` tạo database thành công
- [ ] `rspec` chạy không lỗi

---

### TASK-002: Docker Development Environment
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn chạy project bằng Docker để đảm bảo môi trường đồng nhất.

**Description:**
Setup Docker Compose với Rails, MySQL 8, Redis.

**Acceptance Criteria:**
- [ ] `docker-compose.yml` với 3 services: app, db, redis
- [ ] Dockerfile multi-stage cho Rails
- [ ] Volume mapping cho code hot-reload
- [ ] Environment variables via `.env`

**Test Cases:**
- [ ] `docker-compose up` chạy tất cả services
- [ ] App kết nối được MySQL và Redis
- [ ] Code thay đổi auto-reload

---

### TASK-003: Install Core Gems
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 2 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có đầy đủ gems cần thiết để phát triển.

**Description:**
Thêm các gems theo tech stack đã chọn.

**Acceptance Criteria:**
- [ ] `devise` - Authentication
- [ ] `cancancan` - Authorization
- [ ] `sidekiq` - Background jobs
- [ ] `kaminari` - Pagination
- [ ] `rspec-rails`, `factory_bot_rails` - Testing
- [ ] `rubocop-rails` - Linting
- [ ] `bullet` - N+1 detection

**Test Cases:**
- [ ] `bundle install` thành công
- [ ] Tất cả gems load được trong `rails c`

---

### TASK-004: CI/CD Pipeline
| Field | Value |
|-------|-------|
| **Epic** | Project Setup |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có CI chạy tests tự động khi push code.

**Description:**
GitHub Actions workflow cho test + lint.

**Acceptance Criteria:**
- [ ] `.github/workflows/ci.yml`
- [ ] Run RSpec tests
- [ ] Run RuboCop
- [ ] MySQL service trong CI

**Test Cases:**
- [ ] Push commit → CI triggered
- [ ] CI pass khi tests pass
- [ ] CI fail khi có lint error

---

## Epic: Database Schema

### TASK-005: Design ERD Diagram
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Architect, tôi muốn có ERD diagram để team hiểu database structure.

**Description:**
Thiết kế ERD dựa trên SRS, bao gồm tất cả entities và relationships.

**Acceptance Criteria:**
- [ ] ERD diagram (PNG/SVG)
- [ ] Users, Roles, Permissions tables
- [ ] Teams, Contacts, Deals tables
- [ ] Products, Coupons tables
- [ ] ActivityLogs table
- [ ] All relationships defined

**Test Cases:**
- [ ] Review với team
- [ ] Không có circular dependencies

**Related:** `docs/AnKhangCRM_SRS_v1.0.md`

---

### TASK-006: Core Migrations - Users & Auth
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có bảng users để implement authentication.

**Description:**
Tạo migrations cho Devise users và thông tin nhân viên.

**Acceptance Criteria:**
- [ ] `users` table với Devise columns
- [ ] Extra fields: name, phone, status, team_id
- [ ] Indexes trên email, team_id

**Test Cases:**
- [ ] `rails db:migrate` thành công
- [ ] User.create với valid data OK

---

### TASK-007: Core Migrations - RBAC
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có bảng roles/permissions để implement RBAC động.

**Description:**
Tạo migrations cho dynamic permissions theo SRS PERM-001→007.

**Acceptance Criteria:**
- [ ] `roles` table (name, description, is_system)
- [ ] `permissions` table (subject, action, description)
- [ ] `role_permissions` join table
- [ ] `user_roles` join table
- [ ] `user_permissions` override table (granted boolean)

**Test Cases:**
- [ ] Seed 4 default roles thành công
- [ ] Seed permissions list thành công

**Related:** `docs/tinh-nang/phan-quyen/requirements.md`

---

### TASK-008: Core Migrations - Teams
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 2 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có bảng teams để nhóm nhân viên.

**Acceptance Criteria:**
- [ ] `teams` table (name, description, manager_id, region)
- [ ] FK từ users.team_id → teams.id

**Test Cases:**
- [ ] Team với users association hoạt động

---

### TASK-009: Seed Data - Roles & Permissions
| Field | Value |
|-------|-------|
| **Epic** | Database Schema |
| **Story Points** | 2 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn có 4 roles mặc định sẵn khi deploy.

**Description:**
Seed Super Admin, Tổng Đài, Sale, CSKH với permissions theo SRS.

**Acceptance Criteria:**
- [ ] 4 system roles seeded
- [ ] All permissions seeded (~15 items)
- [ ] Role-permission mappings theo SRS Section 3.2

**Test Cases:**
- [ ] `rails db:seed` thành công
- [ ] Role.find_by(name: 'Super Admin') có tất cả permissions

**Related:** SRS Section 3.2, Section 4.2

---

## Epic: Authentication

### TASK-010: Devise Setup & Configuration
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là User, tôi muốn đăng nhập vào hệ thống bằng username/password.

**Description:**
Setup Devise theo SRS AUTH-001→006.

**Acceptance Criteria:**
- [ ] Login với username/email
- [ ] Password bcrypt cost 12
- [ ] Session timeout 3 ngày
- [ ] Remember me 30 ngày
- [ ] Lock sau 5 lần fail (15 phút)

**Test Cases:**
- [ ] Login với valid credentials → success
- [ ] Login với wrong password → error
- [ ] 5 wrong attempts → account locked

**Related:** SRS Section 4.1

---

### TASK-011: Login Page UI
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 2 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là User, tôi muốn có trang login đẹp và dễ dùng.

**Description:**
Implement login page theo wireframe `index.html`.

**Acceptance Criteria:**
- [ ] Form login (username, password, remember me)
- [ ] Link "Quên mật khẩu"
- [ ] Error message khi login fail
- [ ] Responsive design

**Test Cases:**
- [ ] UI giống wireframe
- [ ] Form submit qua Turbo

**Related:** Wireframe `docs/ui-design/wireframes/index.html`

---

### TASK-012: Password Reset Flow
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là User, tôi muốn reset password nếu quên.

**Description:**
Implement forgot password theo SRS AUTH-003.

**Acceptance Criteria:**
- [ ] Form nhập email
- [ ] Gửi email với reset link
- [ ] Link hết hạn sau 1 giờ
- [ ] Form đổi password mới

**Test Cases:**
- [ ] Request reset → email sent
- [ ] Click link → form hiển thị
- [ ] Submit new password → login OK
- [ ] Click expired link → error

**Related:** Wireframe `docs/ui-design/wireframes/forgot_password.html`

---

### TASK-013: Auth Audit Logging
| Field | Value |
|-------|-------|
| **Epic** | Authentication |
| **Story Points** | 2 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn xem log ai đã login/logout.

**Description:**
Log auth events vào ActivityLog.

**Acceptance Criteria:**
- [ ] Log login success
- [ ] Log login failed (username + IP)
- [ ] Log logout
- [ ] Log password change

**Test Cases:**
- [ ] Login → ActivityLog created với action 'login'
- [ ] Log chứa IP address và user_agent

---

## Epic: Authorization (RBAC)

### TASK-014: CanCanCan Ability Class
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

### TASK-015: Permission Matrix UI
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

# Sprint 2: Core Features Part 1 (Week 3-4)

## Epic: Teams & Employees

### TASK-016: Team CRUD
| Field | Value |
|-------|-------|
| **Epic** | Teams & Employees |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn tạo và quản lý các team trong công ty.

**Acceptance Criteria:**
- [ ] List teams với member count
- [ ] Create/Edit team form
- [ ] Assign manager (optional)
- [ ] Delete team (chỉ khi không có member)

**Test Cases:**
- [ ] Create team → appears in list
- [ ] Delete team có members → error

**Related:** `docs/tinh-nang/doi-nhom/requirements.md`

---

### TASK-017: Employee CRUD
| Field | Value |
|-------|-------|
| **Epic** | Teams & Employees |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn tạo tài khoản cho nhân viên mới.

**Acceptance Criteria:**
- [ ] List employees với filter by team, status
- [ ] Create employee form (username, name, email, phone)
- [ ] Assign roles (multiple)
- [ ] Assign team
- [ ] Activate/Deactivate

**Test Cases:**
- [ ] Create employee → can login
- [ ] Deactivate → cannot login
- [ ] Cannot deactivate self

**Related:** `docs/tinh-nang/nhan-vien/requirements.md`

---

## Epic: Contacts

### TASK-018: Contact Model & Migrations
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có model Contact với đầy đủ fields.

**Acceptance Criteria:**
- [ ] Migration với all fields từ SRS
- [ ] Enums: status, need_type, source
- [ ] Validations: name, phone required
- [ ] Auto-generate code (KH2026-XXX)
- [ ] FULLTEXT index cho search

**Test Cases:**
- [ ] Contact.create với valid data OK
- [ ] Phone format validation works

**Related:** `docs/tinh-nang/khach-hang/requirements.md`

---

### TASK-019: Contact List Page
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn xem danh sách contacts để tìm khách cần xử lý.

**Acceptance Criteria:**
- [ ] Table với columns: code, name, phone, status, assignee, created_at
- [ ] Pagination (25/page)
- [ ] Status badge với màu sắc
- [ ] Quick filter by status
- [ ] Search by name/phone

**Test Cases:**
- [ ] Page load với 100 contacts < 2s
- [ ] Search "0901" → filter đúng
- [ ] Status filter hoạt động

**Related:** Wireframe `contacts_list.html`

---

### TASK-020: Contact Create Form
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Tổng đài, tôi muốn tạo contact mới khi có lead gọi đến.

**Acceptance Criteria:**
- [ ] Form fields theo wireframe
- [ ] Dropdown: loại nhu cầu, nguồn
- [ ] Status tự động = 'new'
- [ ] Code tự động sinh
- [ ] Notification settings sidebar

**Test Cases:**
- [ ] Submit form → contact created
- [ ] Missing required field → validation error
- [ ] Notification triggered (nếu enabled)

**Related:** Wireframe `contacts_form.html`

---

### TASK-021: Pick Contact (⚠️ Critical)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 8 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn "pick" contact mới để nhận việc xử lý.

**Description:**
Core feature với concurrency handling.

**Acceptance Criteria:**
- [ ] Nút "Nhận khách" trên contact row
- [ ] Click → status = picked, assignee = current_user
- [ ] Cooldown 5 phút sau mỗi lần pick
- [ ] DB locking để tránh race condition
- [ ] Real-time update UI (Turbo Stream)
- [ ] Error nếu đã bị pick bởi người khác

**Test Cases:**
- [ ] Pick contact mới → success
- [ ] Pick trong cooldown → error message với countdown
- [ ] 2 users pick cùng lúc → chỉ 1 thành công
- [ ] Sau pick → button ẩn cho users khác (real-time)

**Related:** SRS Section 4.3.5

---

### TASK-022: Contact Detail Page
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn xem đầy đủ thông tin contact đang xử lý.

**Acceptance Criteria:**
- [ ] Display all contact info
- [ ] Status changer dropdown
- [ ] Interaction history timeline
- [ ] Add interaction form

**Test Cases:**
- [ ] Page load với history < 2s
- [ ] Change status → saved + logged

**Related:** Wireframe `contact_detail.html`

---

### TASK-023: Interaction History
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn ghi lại nội dung trao đổi với khách.

**Acceptance Criteria:**
- [ ] Form: nội dung, loại (call/zalo/email/meeting)
- [ ] Timeline hiển thị
- [ ] Chỉ người tạo được xóa

**Test Cases:**
- [ ] Add interaction → appears in timeline
- [ ] Interaction có timestamp và author

---

_(Tiếp tục Sprint 3, 4, 5...)_

---

# Sprint 3: Core Features Part 2 (Week 5)

## Epic: Deals

### TASK-024: Deal Model & Migrations
| Field | Value |
|-------|-------|
| **Epic** | Deals |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có model Deal để track cơ hội bán hàng.

**Acceptance Criteria:**
- [ ] Migration: contact_id, total_value, payment_status, closed_at
- [ ] Enum: payment_status (pending, partial, paid, refunded)
- [ ] Has many deal_products
- [ ] Auto calculate total_value

**Related:** `docs/tinh-nang/co-hoi-ban-hang/requirements.md`

---

### TASK-025: Deal Create Flow
| Field | Value |
|-------|-------|
| **Epic** | Deals |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn tạo deal khi chốt thành công với khách.

**Acceptance Criteria:**
- [ ] Trigger khi contact status → 'chot'
- [ ] Form: chọn products, số lượng, coupon
- [ ] Auto calculate total với discount
- [ ] Save deal + deal_products

---

### TASK-026: Products CRUD
| Field | Value |
|-------|-------|
| **Epic** | Products |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn quản lý danh sách sản phẩm/dịch vụ.

**Related:** `docs/tinh-nang/san-pham/requirements.md`

---

### TASK-027: Coupons CRUD
| Field | Value |
|-------|-------|
| **Epic** | Coupons |
| **Story Points** | 3 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn tạo coupon và gán cho nhân viên specific.

**Acceptance Criteria:**
- [ ] Create coupon (code, type: %, fixed)
- [ ] Expiry date
- [ ] Assign to specific employees

---

# Sprint 4: Notifications (Week 6)

### TASK-028: Notification Rules Engine
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 8 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn tạo rules để tự động gửi thông báo khi có events.

**Related:** SRS Section 4.9

---

### TASK-029: Web Push Notifications
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn nhận push notification khi có contact mới.

---

### TASK-030: Email Notifications
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

---

### TASK-031: Zalo OA Integration
| Field | Value |
|-------|-------|
| **Epic** | Notifications |
| **Story Points** | 8 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là CSKH, tôi muốn gửi tin Zalo ZNS cho khách hàng.

---

# Sprint 5: Dashboard & Deploy (Week 7-8)

### TASK-032: Dashboard KPI Cards
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 3 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

---

### TASK-033: Dashboard Charts
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 5 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

---

### TASK-034: Activity Logs Viewer
| Field | Value |
|-------|-------|
| **Epic** | Audit |
| **Story Points** | 5 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

---

### TASK-035: Production Deployment
| Field | Value |
|-------|-------|
| **Epic** | Deployment |
| **Story Points** | 8 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

---

# 📌 Task Status Legend

| Status | Meaning |
|--------|---------|
| Backlog | Chưa bắt đầu |
| Todo | Đã plan vào sprint |
| In Progress | Đang làm |
| Review | Chờ review |
| Done | Hoàn thành |
| Blocked | Bị chặn |

---

# 📊 Summary

| Priority | Count |
|----------|-------|
| 🔴 Critical | 15 |
| 🟡 High | 12 |
| 🟢 Medium | 8 |

**Total Tasks: 35**
