# Sprint 6: Smart Routing v2 + Province (Week 11-12)

> **Duration**: 2 tuần
> **Focus**: 🔴 Sale & Tổng đài Priority
> **Total Tasks**: 12

---

## Epic: Database Cleanup & Migrations

### TASK-060: Remove Pick Rules from ServiceType
| Field            | Value          |
| ---------------- | -------------- |
| **Epic**         | Database       |
| **Story Points** | 2              |
| **Priority**     | 🔴 Critical     |
| **Status**       | ✅ Done        |

**Description:**
Xóa các columns không còn sử dụng trong ServiceType.

**Acceptance Criteria:**
- [ ] Migration remove `max_pick_per_day` từ `service_types`
- [ ] Migration remove `pick_cooldown_minutes` từ `service_types`
- [ ] Xóa validations trong model
- [ ] Xóa UI fields trong Admin form

**Test Cases:**
- [ ] `rails db:migrate` thành công
- [ ] RSpec pass (có thể cần update tests)

---

### TASK-061: Provinces & ProvinceRegions Tables
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Database   |
| **Story Points** | 3          |
| **Priority**     | 🔴 Critical |
| **Status**       | ✅ Done    |

**Description:**
Tạo bảng Province (63 tỉnh) và ProvinceRegion (join table many-to-many).

**Acceptance Criteria:**
- [ ] Migration `provinces` (name, code, position, active)
- [ ] Migration `province_regions` (province_id, region_id)
- [ ] Model Province với associations
- [ ] Update Region model với `has_many :provinces, through:`
- [ ] Seed 63 tỉnh thành Việt Nam

**Test Cases:**
- [ ] `rails db:seed` tạo 63 provinces
- [ ] Province.first.regions trả về đúng vùng

**Depends on:** TASK-060

---

### TASK-062: UserServiceTypeLimit Table
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Database   |
| **Story Points** | 3          |
| **Priority**     | 🔴 Critical |
| **Status**       | ✅ Done    |

**Description:**
Bảng mới lưu giới hạn pick theo từng nhân viên + loại nhu cầu.

**Acceptance Criteria:**
- [ ] Migration `user_service_type_limits` (user_id, service_type_id, max_pick_per_day)
- [ ] Model with validations (max_pick_per_day > 0)
- [ ] Unique index on [user_id, service_type_id]
- [ ] User `has_many :user_service_type_limits`

**Test Cases:**
- [ ] Không thể tạo duplicate user + service_type
- [ ] max_pick_per_day phải > 0

**Depends on:** TASK-060

---

### TASK-063: Add Province to Contact
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Database   |
| **Story Points** | 2          |
| **Priority**     | 🔴 Critical |
| **Status**       | ✅ Done    |

**Description:**
Thêm province_id và address vào Contact.

**Acceptance Criteria:**
- [ ] Migration add `province_id` (FK) to contacts
- [ ] Migration add `address` (string, optional) to contacts
- [ ] Contact `belongs_to :province, optional: true`
- [ ] Province `has_many :contacts`

**Test Cases:**
- [ ] Contact có thể lưu với province_id
- [ ] Contact.first.province.name trả về tên tỉnh

**Depends on:** TASK-061

---

### TASK-064: Simplify Contact Status (10 → 4)
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Database   |
| **Story Points** | 5          |
| **Priority**     | 🔴 Critical |
| **Status**       | ✅ Done    |

**Description:**
Đơn giản hóa enum status từ 10 xuống 4 trạng thái.

**Acceptance Criteria:**
- [ ] Update enum trong Contact model
- [ ] Data migration: map trạng thái cũ → mới
  - `new_contact` → `new`
  - `potential`, `in_progress`, `potential_old` → `potential`
  - `failed`, `cskh_l1`, `cskh_l2` → `failed`
  - `closed_new`, `closed_old`, `closed` → `closed`
- [ ] Xóa StatusMachine concern (không cần state machine phức tạp)
- [ ] Update I18n translations
- [ ] Update UI badges/colors

**Test Cases:**
- [ ] Data migration chạy đúng
- [ ] Contact.statuses có 4 keys
- [ ] RSpec status tests pass

**Depends on:** TASK-060

---

## Epic: Smart Routing v2

### TASK-065: ENV PICK_COOLDOWN_MINUTES
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Smart Routing |
| **Story Points** | 1          |
| **Priority**     | 🟡 High     |
| **Status**       | ✅ Done     |

**Description:**
Fix cứng cooldown = 5 phút qua ENV.

**Acceptance Criteria:**
- [ ] Thêm `PICK_COOLDOWN_MINUTES=5` vào `.env.example`
- [ ] PickEligibilityService đọc từ ENV thay vì ServiceType
- [ ] Fallback default = 5 nếu ENV không set

**Test Cases:**
- [ ] Cooldown hoạt động đúng 5 phút

**Depends on:** TASK-060

---

### TASK-066: Refactor SmartRoutingService (3 Layers)
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Smart Routing |
| **Story Points** | 8          |
| **Priority**     | 🔴 Critical |
| **Status**       | Backlog    |

**Description:**
Viết lại SmartRoutingService theo cơ chế 3 lớp mới.

**Acceptance Criteria:**
- [ ] Layer 1: Random công bằng (round-robin trong ngày)
- [ ] Layer 2: Pool pick theo vùng miền (sau 2 phút)
- [ ] Layer 3: Pool pick toàn quốc (sau 2 phút nữa)
- [ ] Điều kiện NV trong pool:
  - Thuộc Team của loại nhu cầu
  - Có UserServiceTypeLimit > 0
  - Chưa đạt limit trong ngày
  - Hết cooldown 5 phút
- [ ] Track round-robin pool (reset khi tất cả đã random)
- [ ] Jobs: SmartRoutingLayer2Job, SmartRoutingLayer3Job

**Test Cases:**
- [ ] Layer 1 random không trùng lặp đến khi hết pool
- [ ] Layer 2 trigger sau 2 phút
- [ ] Layer 3 trigger sau 4 phút

**Depends on:** TASK-062, TASK-063, TASK-065

---

### TASK-067: Update PickEligibilityService
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Smart Routing |
| **Story Points** | 3          |
| **Priority**     | 🔴 Critical |
| **Status**       | ✅ Done    |

**Description:**
Cập nhật service kiểm tra điều kiện pick theo logic mới.

**Acceptance Criteria:**
- [ ] Check UserServiceTypeLimit thay vì ServiceType.max_pick_per_day
- [ ] NV không có limit → không eligible
- [ ] Count picks trong ngày đúng theo service_type

**Test Cases:**
- [ ] NV không có limit → error message
- [ ] NV đạt limit → error message
- [ ] NV eligible → can pick

**Depends on:** TASK-062

---

## Epic: Admin UI Updates

### TASK-068: Province CRUD Admin
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Admin UI   |
| **Story Points** | 3          |
| **Priority**     | 🟡 High     |
| **Status**       | Backlog    |

**Description:**
Màn hình quản lý tỉnh thành cho Admin.

**Acceptance Criteria:**
- [ ] List provinces với pagination
- [ ] Create/Edit form (name, code, position, active)
- [ ] Delete (nếu không có contact nào)
- [ ] Bulk import từ seed available

**Test Cases:**
- [ ] CRUD hoạt động đúng
- [ ] Delete province có contact → error

**Depends on:** TASK-061

---

### TASK-069: Region → Provinces Selection
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Admin UI   |
| **Story Points** | 3          |
| **Priority**     | 🟡 High     |
| **Status**       | Backlog    |

**Description:**
Thêm multi-select provinces vào form Region.

**Acceptance Criteria:**
- [ ] Form Region có multi-select chọn provinces
- [ ] Save tạo/xóa ProvinceRegion records
- [ ] Hiển thị list provinces trong Region show page

**Test Cases:**
- [ ] Chọn provinces → save đúng
- [ ] Bỏ chọn → xóa relation

**Depends on:** TASK-061, TASK-068

---

### TASK-070: Employee ServiceType Limits UI
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Admin UI   |
| **Story Points** | 5          |
| **Priority**     | 🔴 Critical |
| **Status**       | ✅ Done    |

**Description:**
Thêm cài đặt giới hạn pick theo loại nhu cầu trong form Employee.

**Acceptance Criteria:**
- [ ] Nested form với danh sách ServiceType
- [ ] Mỗi row: ServiceType name + max_pick_per_day input
- [ ] Add/Remove service types
- [ ] Save tạo/update UserServiceTypeLimit records

**Test Cases:**
- [ ] Thêm limit → NV có thể pick loại đó
- [ ] Xóa limit → NV không thể pick loại đó

**Depends on:** TASK-062

---

### TASK-071: Call Center Form + Province Dropdown
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Tổng đài   |
| **Story Points** | 2          |
| **Priority**     | 🔴 Critical |
| **Status**       | Backlog    |

**Description:**
Thêm dropdown chọn tỉnh vào form tạo Contact của Tổng đài.

**Acceptance Criteria:**
- [ ] Dropdown provinces (optional)
- [ ] Text field address (optional)
- [ ] Contact saved với province_id

**Test Cases:**
- [ ] Tạo contact có province → saved đúng
- [ ] Province truyền xuống Smart Routing

**Depends on:** TASK-063

---

## 📊 Sprint 6 Summary

| Priority    | Count |
| ----------- | ----- |
| 🔴 Critical  | 9     |
| 🟡 High      | 3     |

**Total Story Points:** ~40

**Dependencies:**

```
TASK-060 (cleanup)
    ├── TASK-061 (provinces) → TASK-063 (contact) → TASK-071 (form)
    │                       → TASK-068 (admin) → TASK-069 (region UI)
    ├── TASK-062 (limits) → TASK-067 (eligibility) → TASK-066 (routing)
    │                     → TASK-070 (employee UI)
    ├── TASK-064 (status simplify)
    └── TASK-065 (ENV cooldown)
```

**Recommended Order:**
1. TASK-060 → TASK-064 → TASK-065 (cleanup + simplify)
2. TASK-061 → TASK-068 → TASK-069 (provinces)
3. TASK-062 → TASK-070 (limits)
4. TASK-063 → TASK-071 (contact + form)
5. TASK-067 → TASK-066 (smart routing)
