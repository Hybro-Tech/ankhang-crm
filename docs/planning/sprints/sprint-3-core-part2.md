# Sprint 3: Core Features Part 2 (Week 5)

> **Duration**: Week 5  
> **Focus**: Contacts, Pick Mechanism, Deals, Products  
> **Total Tasks**: 13

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
> Là Developer, tôi muốn có model Contact với đầy đủ fields.

**Acceptance Criteria:**
- [ ] Migration với all fields từ SRS (Code: KH2026-XXX)
- [ ] Enums: status, need_type, source
- [ ] Validations: name, phone required
- [ ] Database Indexing (search performance)

**Test Cases:**
- [ ] Contact.create với valid data OK

---

---

### TASK-022b: Xây dựng Pick Rules Engine (Backend)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn cấu hình giới hạn nhận khách cho từng loại dịch vụ.

**Acceptance Criteria:**
- [ ] Update `service_types` table: add `max_pick_per_day` column
- [ ] UI: Form edit Service Type có input cho field này
- [ ] Backend Service: `PickEligibilityService` để check rule này

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
> Là Tổng đài, tôi muốn tạo contact mới khi có lead gọi đến.

**Acceptance Criteria:**
- [ ] Form fields chuẩn SRS
- [ ] Dropdown "Loại nhu cầu" (Load từ DB - Dynamic)
- [ ] Auto assigning "Mới" status

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

**Acceptance Criteria:**
- [ ] Table columns: code, name, phone, status, assignee
- [ ] Pagination & Filtering (Status, Team)
- [ ] Search by Phone/Name

---

### TASK-022: Chức năng Nhận khách (⚠️ Quan trọng)
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 8 |
| **Priority** | 🔴 Critical |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn "pick" contact mới nhưng phải tuân thủ rule của công ty.

**Description:**
Core feature với concurrency handling và dynamic rules checking.

**Acceptance Criteria:**
- [ ] Nút "Nhận khách" chỉ hiện khi đủ điều kiện
- [ ] **Logic Check**:
    - [ ] Cooldown 5 phút.
    - [ ] **Dynamic Limit**: Check số lượng đã pick trong ngày theo loại nhu cầu (VD: Kế toán < 2).
- [ ] DB Locking (Transaction)
- [ ] Real-time update: Ẩn nút với users khác khi có người pick thành công.
- [ ] **Admin Re-assign**: Admin có nút chuyển contact cho người khác.

**Test Cases:**
- [ ] Pick -> Success (Update Assignee, Status=Processing)
- [ ] Pick quá giới hạn -> Error "Bạn đã nhận đủ số lượng khách loại này trong ngày"
- [ ] Admin Re-assign -> Success + Logged

---

### TASK-023: Chi tiết Contact & Lịch sử chăm sóc
| Field | Value |
|-------|-------|
| **Epic** | Contacts |
| **Story Points** | 5 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Sale, tôi muốn xem chi tiết và ghi lại lịch sử chăm sóc.

**Acceptance Criteria:**
- [ ] View Detail Contact
- [ ] Log Interaction (Call/Zalo) -> Timeline view
- [ ] Change Status flow

---

## Epic: Deals

### TASK-025: Tạo Model & Migration Deal
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
- [ ] Migration: contact_id, total_value, payment_status, closed_by, closed_at, notes
- [ ] Enum: payment_status (pending, partial, paid, refunded)
- [ ] belongs_to :contact
- [ ] has_many :deal_products
- [ ] Auto calculate total_value từ deal_products

**Test Cases:**
- [ ] Deal.create với contact OK
- [ ] total_value cập nhật khi thêm/xóa products
- [ ] payment_status transitions hợp lệ

---

### TASK-026: Liên kết Deal - Products
| Field | Value |
|-------|-------|
| **Epic** | Deals |
| **Story Points** | 2 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Developer, tôi muốn 1 deal có thể có nhiều sản phẩm.

**Acceptance Criteria:**
- [ ] `deal_products` table: deal_id, product_id, quantity, unit_price, coupon_id
- [ ] belongs_to :deal, :product, :coupon (optional)
- [ ] Validate quantity > 0

**Test Cases:**
- [ ] Add product to deal → total updated
- [ ] Apply coupon → discounted price calculated

---

### TASK-027: Luồng tạo Deal
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
- [ ] Modal/Page: chọn products từ list
- [ ] Số lượng input cho mỗi product
- [ ] Chọn coupon (optional, chỉ coupon assigned cho user)
- [ ] Auto calculate total với discount
- [ ] Save deal + deal_products
- [ ] Update contact status

**Test Cases:**
- [ ] Chọn 2 products → total = sum
- [ ] Apply coupon 10% → total giảm 10%
- [ ] Submit → Deal created, contact status = chot

---

## Epic: Products

### TASK-028: Quản lý Sản phẩm (CRUD)
| Field | Value |
|-------|-------|
| **Epic** | Products |
| **Story Points** | 3 |
| **Priority** | 🟡 High |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin, tôi muốn quản lý danh sách sản phẩm/dịch vụ.

**Acceptance Criteria:**
- [ ] List products với filter by status (active/inactive)
- [ ] Create/Edit form: code, name, description, base_price, status
- [ ] Deactivate (không xóa, chỉ ẩn)
- [ ] Search by name/code

**Test Cases:**
- [ ] Create product → appears in list
- [ ] Deactivate → không hiện trong deal form
- [ ] Edit price → saved

---

## Epic: Coupons

### TASK-029: Quản lý Coupon (CRUD)
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
- [ ] Create coupon: code, description, discount_type (percent/fixed), value, expiry_date
- [ ] Assign to specific employees (multi-select)
- [ ] Coupon chỉ hiện cho employees được gán
- [ ] Validate expiry date

**Test Cases:**
- [ ] Create coupon → assigned employees thấy trong deal form
- [ ] Expired coupon → không thể apply
- [ ] Non-assigned employee → không thấy coupon

---

### TASK-030: Danh sách & Chi tiết Deal
| Field | Value |
|-------|-------|
| **Epic** | Deals |
| **Story Points** | 3 |
| **Priority** | 🟢 Medium |
| **Assignee** | |
| **Status** | Backlog |

**User Story:**
> Là Admin/Sale, tôi muốn xem danh sách deals và chi tiết.

**Acceptance Criteria:**
- [ ] List deals: contact name, total_value, payment_status, closed_by, closed_at
- [ ] Filter by payment_status, date range
- [ ] Detail page: products list, coupon applied, payment history
- [ ] Update payment_status

**Test Cases:**
- [ ] Filter by date → correct results
- [ ] Update payment_status → logged

---

## 📊 Sprint 3 Summary

| Priority | Count |
|----------|-------|
| 🟡 High | 4 |
| 🟢 Medium | 2 |

**Total Story Points:** ~48 (Heavy Sprint)

**Dependencies:**
- Sprint 2 completed (Contacts working)
- Products seeded for testing
