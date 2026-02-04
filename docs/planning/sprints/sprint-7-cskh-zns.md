# Sprint 7: CSKH Workspace + ZNS (Week 13-14)

> **Duration**: 2 tuần
> **Focus**: 🟡 CSKH Priority
> **Total Tasks**: 8

---

## Epic: CSKH Workspace

### TASK-072: CSKH Workspace Layout
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | CSKH       |
| **Story Points** | 3          |
| **Priority**     | 🔴 Critical |
| **Status**       | Backlog    |

**Description:**
Tạo màn hình workspace riêng cho CSKH với 2 tabs.

**Acceptance Criteria:**
- [ ] Route `/cskh/workspace`
- [ ] Controller `Cskh::WorkspaceController`
- [ ] Layout với 2 tabs: Danh sách đen, Danh sách thanh tra
- [ ] Tab switching với Turbo Frames
- [ ] KPI header (số contact blacklist, số cần thanh tra)

**Test Cases:**
- [ ] CSKH access được `/cskh/workspace`
- [ ] Sale không access được (403)
- [ ] Tabs switch không reload page

**Depends on:** Sprint 6 completed

---

### TASK-073: Blacklist Tab - Failed Contacts
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | CSKH       |
| **Story Points** | 3          |
| **Priority**     | 🔴 Critical |
| **Status**       | Backlog    |

**Description:**
Tab hiển thị contact thất bại và contact không có update 24h.

**Acceptance Criteria:**
- [ ] Scope `Contact.blacklist`:
  - `status = failed` OR
  - `assigned_user_id IS NOT NULL AND last_interaction_at < 24.hours.ago`
- [ ] Add `last_interaction_at` column to contacts (cached)
- [ ] Update `last_interaction_at` when Interaction created
- [ ] Table columns: code, name, phone, sale phụ trách, lý do blacklist, actions

**Test Cases:**
- [ ] Contact failed xuất hiện trong list
- [ ] Contact không tương tác 24h xuất hiện trong list

**Depends on:** TASK-072

---

### TASK-074: CSKH "Cướp khách" Action
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | CSKH       |
| **Story Points** | 5          |
| **Priority**     | 🔴 Critical |
| **Status**       | Backlog    |

**Description:**
Cho phép CSKH nhận contact từ blacklist về chăm sóc.

**Acceptance Criteria:**
- [ ] Button "Nhận chăm sóc" trên mỗi row blacklist
- [ ] Action: 
  - `contact.assigned_user_id = current_user`
  - `contact.status = potential` (quay lại tiềm năng)
  - `contact.assigned_at = now`
- [ ] Notification cho Sale cũ (optional)
- [ ] ActivityLog ghi lại action `cskh_takeover`

**Test Cases:**
- [ ] Click "Nhận" → contact gán cho CSKH
- [ ] Contact biến mất khỏi blacklist
- [ ] Log ghi lại hành động

**Depends on:** TASK-073

---

### TASK-075: Inspection Tab - Long Appointments
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | CSKH       |
| **Story Points** | 3          |
| **Priority**     | 🟡 High     |
| **Status**       | Backlog    |

**Description:**
Tab hiển thị contact có lịch hẹn quá xa.

**Acceptance Criteria:**
- [ ] Setting `max_appointment_days` (default: 30)
- [ ] Scope `Contact.long_appointment`:
  - `next_appointment > today + max_appointment_days`
- [ ] Table columns: code, name, phone, sale, lịch hẹn, khoảng cách (ngày)

**Test Cases:**
- [ ] Contact có lịch hẹn > 30 ngày xuất hiện
- [ ] Thay đổi setting → list update

**Depends on:** TASK-072

---

### TASK-076: Add Setting max_appointment_days
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Settings   |
| **Story Points** | 1          |
| **Priority**     | 🟡 High     |
| **Status**       | Backlog    |

**Description:**
Thêm setting cho CSKH thanh tra.

**Acceptance Criteria:**
- [ ] Add `max_appointment_days` vào seeds (default: 30)
- [ ] Hiển thị trong Admin Settings page
- [ ] Editable bởi Admin

**Test Cases:**
- [ ] Setting lưu và load đúng
- [ ] CSKH workspace sử dụng giá trị này

---

## Epic: ZNS Integration (Mock)

### TASK-077: ZNS Auto Send Job (24h)
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | ZNS        |
| **Story Points** | 5          |
| **Priority**     | 🟡 High     |
| **Status**       | Backlog    |

**Description:**
Job tự động gửi ZNS sau 24h khi contact được tạo.

**Acceptance Criteria:**
- [ ] `SendZnsJob` với delay 24 hours
- [ ] Trigger after_create_commit trên Contact
- [ ] Check contact vẫn tồn tại khi job chạy
- [ ] Ghi log ZNS đã gửi (mock)
- [ ] Tạo `ZnsLog` model (contact_id, template_id, sent_at, status)

**Test Cases:**
- [ ] Contact tạo → job scheduled sau 24h
- [ ] Job chạy → log created

**Depends on:** Sprint 6 completed

---

### TASK-078: ZNS Manual Send UI (CSKH)
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | ZNS        |
| **Story Points** | 5          |
| **Priority**     | 🟡 High     |
| **Status**       | Backlog    |

**Description:**
Màn hình gửi ZNS thủ công cho CSKH.

**Acceptance Criteria:**
- [ ] Route `/cskh/zns`
- [ ] Filter form:
  - Loại nhu cầu (multi-select)
  - Vùng miền (multi-select)
  - Trạng thái (multi-select)
  - Thời gian tạo (date range)
  - Thời gian cập nhật (date range)
- [ ] Result list với checkboxes
- [ ] Select all / Deselect all
- [ ] Template dropdown (mock templates)
- [ ] Button "Gửi ZNS" (mock - chỉ log)

**Test Cases:**
- [ ] Filter hoạt động đúng
- [ ] Chọn contacts + template → gửi (mock)
- [ ] Log tạo ra đúng số lượng records

**Depends on:** TASK-077

---

### TASK-079: ZNS Log & History
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | ZNS        |
| **Story Points** | 3          |
| **Priority**     | 🟢 Medium   |
| **Status**       | Backlog    |

**Description:**
Xem lịch sử gửi ZNS.

**Acceptance Criteria:**
- [ ] Route `/cskh/zns/history`
- [ ] List ZnsLog với pagination
- [ ] Filter by date, status
- [ ] Link to contact detail

**Test Cases:**
- [ ] History hiển thị đúng logs
- [ ] Click contact → redirect

**Depends on:** TASK-077

---

## 📊 Sprint 7 Summary

| Priority    | Count |
| ----------- | ----- |
| 🔴 Critical  | 3     |
| 🟡 High      | 4     |
| 🟢 Medium    | 1     |

**Total Story Points:** ~28

**Dependencies:**

```
Sprint 6 completed
    │
    ├── TASK-072 (layout)
    │   ├── TASK-073 (blacklist) → TASK-074 (cướp khách)
    │   └── TASK-075 (inspection) ← TASK-076 (setting)
    │
    └── TASK-077 (auto ZNS)
        └── TASK-078 (manual ZNS) → TASK-079 (history)
```

**Recommended Order:**
1. TASK-076 (setting)
2. TASK-072 → TASK-073 → TASK-074 (CSKH workspace)
3. TASK-075 (inspection)
4. TASK-077 → TASK-078 → TASK-079 (ZNS)

---

## Phase 2 Backlog (Future)

| Task | Description |
|------|-------------|
| Zalo OA Integration | Real API connection |
| ZNS Templates Management | Admin CRUD templates |
| ZNS Analytics | Delivery rate, open rate |
| Deals Module | Sales opportunities |
| Products & Coupons | Product catalog |
