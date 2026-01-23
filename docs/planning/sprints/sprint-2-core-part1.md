# Sprint 2: Core Features Part 1 (Week 3-4)

> **Duration**: Week 3-4  
> **Focus**: Teams, Employees (RBAC)  
> **Total Tasks**: 2

---

## Epic: Teams & Employees

### TASK-017: Quản lý Team (CRUD)
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

### TASK-018: Quản lý Nhân viên (CRUD)
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



## 📊 Sprint 2 Summary

| Priority | Count |
|----------|-------|
| 🟡 High | 2 |

**Total Story Points:** ~8

**Dependencies:**
- Sprint 1 completed (Auth + RBAC working)
