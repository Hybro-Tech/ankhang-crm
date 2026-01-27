# Sprint 2: Pre-Tet (UI/UX Tổng đài & Sale)

> **Duration**: 26/01/2026 - 13/02/2026 (2.5 tuần)  
> **Focus**: Teams, Employees, Contacts, Dashboard UI/UX  
> **Goal**: Demo được flow Tổng đài tạo Contact → Sale xem danh sách  
> **Total Tasks**: 9

---

## Epic: Teams & Employees

### TASK-017: Quản lý Team (CRUD)
| Field | Value |
|-------|-------|
| **Epic** | Teams & Employees |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | Antigravity |
| **Status** | Completed |

**User Story:**
> Là Admin, tôi muốn tạo và quản lý các team trong công ty.

**Acceptance Criteria:**
- [x] List teams với member count
- [x] Create/Edit team form
- [x] Assign manager (optional)
- [x] Delete team (chỉ khi không có member)

**Test Cases:**
- [x] Create team → appears in list
- [x] Delete team có members → error

**Related:** `docs/tinh-nang/doi-nhom/requirements.md`

---

### TASK-018: Quản lý Nhân viên (CRUD)
| Field | Value |
|-------|-------|
| **Epic** | Teams & Employees |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | Antigravity |
| **Status** | Completed |

**User Story:**
> Là Admin, tôi muốn tạo tài khoản cho nhân viên mới.

**Acceptance Criteria:**
- [x] List employees với filter by team, status
- [x] Create employee form (username, name, email, phone)
- [x] Assign roles (multiple)
- [x] Assign team (multiple - many-to-many)
- [x] Activate/Deactivate

**Test Cases:**
- [x] Create employee → can login
- [x] Deactivate → cannot login
- [x] Cannot deactivate self

**Related:** `docs/tinh-nang/nhan-vien/requirements.md`

---

## Epic: Lịch làm việc (Organization)

### TASK-047: Quản lý Ngày nghỉ/Lễ (CRUD)
| Field | Value |
|-------|-------|
| **Epic** | Organization |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | Antigravity |
| **Status** | Completed |

**User Story:**
> Là Admin, tôi muốn quản lý lịch nghỉ lễ của công ty để Smart Routing hoạt động đúng.

**Description:**
Quản lý ngày nghỉ/lễ để hệ thống biết khi nào là ngoài giờ làm việc.

**Acceptance Criteria:**
- [x] Seed sẵn lịch nghỉ lễ VN (Tết, 30/4, 1/5, 2/9, Giỗ tổ...)
- [x] Admin thêm/sửa/xóa ngày nghỉ
- [x] UI: Calendar view hoặc List view với date picker
- [ ] Cronjob hoặc manual tạo lịch cho năm mới (deferred)
- [x] API: Check ngày X có phải ngày nghỉ không

**Test Cases:**
- [x] Seed data có đủ ngày lễ VN
- [x] Add ngày nghỉ → appears in calendar
- [x] Delete ngày nghỉ → removed
- [x] Check API trả về đúng

---

### TASK-048: Quản lý Danh sách đi làm Thứ 7 (CRUD)
| Field | Value |
|-------|-------|
| **Epic** | Organization |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | Antigravity |
| **Status** | Completed |

**User Story:**
> Là Admin, tôi muốn tạo danh sách nhân viên đi làm vào ngày Thứ 7 cụ thể.

**Description:**
Mỗi Thứ 7, chỉ một số nhân viên đi làm. Admin cần tạo danh sách này trước.

**Acceptance Criteria:**
- [x] `saturday_schedules` table: date, description
- [x] `saturday_schedule_users` join table: schedule_id, user_id
- [x] UI: Chọn ngày Thứ 7 → Checkbox list nhân viên
- [x] Validate: Chỉ cho chọn ngày Thứ 7
- [ ] Smart Routing sử dụng danh sách này

**Test Cases:**
- [x] Create schedule cho Thứ 7 → success
- [x] Create schedule cho Thứ 2 → error
- [x] Check API trả về đúng danh sách nhân viên

---

## Epic: Contacts

### TASK-019: Tạo Model & Migration Contact
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn có model Contact với đầy đủ fields theo SRS v2.

**Acceptance Criteria:**
- [ ] Migration với all fields từ SRS v2 Section 5.1
- [ ] Auto-generate code: KH2026-XXX
- [ ] Enums: status (theo state machine SRS 5.2), source
- [ ] Foreign keys: team_id, assigned_user_id, created_by_id
- [ ] Validations: name, phone required
- [ ] Check trùng SĐT (unique constraint)
- [ ] Database Indexing (phone, status, team_id)

**Test Cases:**
- [ ] Contact.create với valid data OK
- [ ] Duplicate phone → error
- [ ] Auto code generated

---

### TASK-020: Trang danh sách Contact
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn xem danh sách contacts để tìm khách cần xử lý.

**Description:**
Trang chính cho Sale xem và quản lý khách hàng.

**Acceptance Criteria:**
- [ ] Table columns: code, name, phone, status, loại nhu cầu, assignee, created_at
- [ ] Pagination (Kaminari)
- [ ] Filtering: Status, Team, Loại nhu cầu
- [ ] Search by Phone/Name
- [ ] Sort: Mới nhất trước, Chưa ai nhận lên đầu
- [ ] Nút "Nhận khách" cho contacts chưa có owner

**Test Cases:**
- [ ] List render đúng columns
- [ ] Filter by status works
- [ ] Search by phone works
- [ ] Pagination works

**Related:** Wireframe `docs/ui-design/wireframes/contacts_list.html`

---

### TASK-021: Form tạo Contact mới
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Tổng đài, tôi muốn tạo contact mới nhanh chóng khi có lead gọi đến.

**Description:**
Form tối ưu cho việc nhập nhanh thông tin khách hàng.

**Acceptance Criteria:**
- [ ] Form fields theo SRS v2 Section 5.1
- [ ] Dropdown "Loại nhu cầu" (load từ DB - ServiceType)
- [ ] Dropdown "Nguồn" (Ladi Zalo/Hotline, FB, Google, Giới thiệu, Khác)
- [ ] Auto assign status = "Mới"
- [ ] Auto assign created_by = current_user
- [ ] Check trùng SĐT real-time (Turbo)
- [ ] Zalo Link & Zalo QR upload (optional)
- [ ] Success → Redirect to list hoặc tạo tiếp

**Test Cases:**
- [ ] Submit valid form → Contact created
- [ ] Duplicate phone → Warning message
- [ ] Required fields empty → Validation error

**Related:** Wireframe `docs/ui-design/wireframes/contact_form.html`

---

## Epic: Dashboard

### TASK-049: Dashboard Tổng đài (UI)
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 3 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Tổng đài, tôi muốn có màn hình tối ưu để nhập Contact nhanh và xem thống kê.

**Description:**
Dashboard dành riêng cho role Tổng đài, theo SRS v2 Section 10.

**Acceptance Criteria:**
- [ ] Form tạo Contact inline (embedded, không cần navigate)
- [ ] Thống kê số Contact đã tạo:
  - [ ] Hôm nay
  - [ ] Tuần này
  - [ ] Tháng này
- [ ] Danh sách Contact mới tạo (10 gần nhất)
- [ ] Quick link: Xem tất cả Contact của mình

**Test Cases:**
- [ ] Tổng đài login → Redirect to Dashboard Tổng đài
- [ ] Thống kê hiển thị đúng
- [ ] Form submit → Contact created, list updated

---

### TASK-050: Dashboard Sale (UI)
| Field | Value |
|-------|-------|
| **Epic** | Dashboard |
| **Story Points** | 5 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn có màn hình tập trung để xem Contact mới và lịch hẹn.

**Description:**
Dashboard dành riêng cho role Sale, theo SRS v2 Section 10.

**Acceptance Criteria:**
- [ ] **Khu vực Notification:** Contact mới cần nhận (Chưa có real-time, F5 refresh)
- [ ] **Khu vực Lịch hẹn:** DS hẹn trong 1 tuần tới
- [ ] **Khu vực DS Khách:** 
  - [ ] Sort: Chưa ai nhận → Mới nhất
  - [ ] Nút "Nhận khách" với basic validation
- [ ] **Khu vực Đua top:** Bảng xếp hạng Sale (số khách đã pick)
- [ ] Responsive design cho mobile

**Test Cases:**
- [ ] Sale login → Redirect to Dashboard Sale
- [ ] Contact mới hiển thị trong list
- [ ] Click "Nhận khách" → Contact assigned
- [ ] Lịch hẹn hiển thị đúng

**Related:** SRS v2 Section 10 - Dashboard Sale

---

## 📊 Sprint 2 Summary

| Priority | Count |
|----------|-------|
| 🔴 Critical | 5 |
| 🟡 High | 4 |

**Total Story Points:** ~33

**Dependencies:**
- Sprint 1 completed (Auth + RBAC working)
- ServiceType (Loại nhu cầu) seeded

**Success Criteria:**
- [x] Admin có thể tạo Team, Employee
- [ ] Admin có thể tạo lịch nghỉ, DS đi làm Thứ 7
- [ ] Tổng đài có thể tạo Contact từ Dashboard
- [ ] Sale có thể xem danh sách Contact từ Dashboard
- [ ] Demo được flow cơ bản cho stakeholder trước Tết
