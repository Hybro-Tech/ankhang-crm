# 💰 Module: Deals

> **Module ID**: DEAL  
> **Priority**: Cao  
> **Phase**: 1

---

## 1. Tổng Quan

Module quản lý thông tin khi chốt deal thành công. Mỗi deal có thể chứa **nhiều sản phẩm**, mỗi SP có số lượng, giá và thời điểm chốt riêng.

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| DEAL-001 | Tạo deal khi chốt contact | Cao | 1 |
| DEAL-002 | Thêm nhiều SP vào 1 deal | Cao | 1 |
| DEAL-003 | Mỗi SP có số lượng, giá, thời điểm chốt | Cao | 1 |
| DEAL-004 | Cập nhật trạng thái thanh toán | Cao | 1 |
| DEAL-005 | Xem lịch sử thanh toán | Trung | 1 |

---

## 3. Thông Tin Deal

### 3.1 Deal (Header)

| Field | Type | Required | Ghi chú |
|-------|------|----------|---------|
| id | int | Auto | PK |
| contact_id | int | ✅ | FK contacts |
| total_amount | decimal | Auto | Tổng giá trị deal |
| payment_status | enum | ✅ | Tình trạng thanh toán |
| closed_by | int | ✅ | FK users (người chốt) |
| closed_at | datetime | ✅ | Ngày chốt deal đầu tiên |
| notes | text | | Ghi chú |
| created_at | datetime | Auto | |
| updated_at | datetime | Auto | |

### 3.2 Deal Products (Chi tiết SP trong Deal)

| Field | Type | Required | Ghi chú |
|-------|------|----------|---------|
| id | int | Auto | PK |
| deal_id | int | ✅ | FK deals |
| product_id | int | ✅ | FK products |
| quantity | int | ✅ | Số lượng (default: 1) |
| unit_price | decimal | ✅ | Giá thành từng SP |
| closed_at | datetime | ✅ | Thời điểm chốt SP này |
| notes | text | | Ghi chú riêng cho SP |

---

## 4. Payment History

Bảng lưu lịch sử thay đổi thanh toán.

| Field | Type | Mô tả |
|-------|------|-------|
| id | int | PK |
| deal_id | int | FK → Deal |
| old_status | enum | Trạng thái cũ |
| new_status | enum | Trạng thái mới |
| amount | decimal | Số tiền thay đổi |
| changed_by | int | FK → User |
| notes | text | Ghi chú |
| created_at | datetime | Thời điểm |

---

## 5. API Endpoints

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/deals` | List deals | `deals.view` |
| GET | `/api/v1/deals/:id` | Deal detail | `deals.view` |
| POST | `/api/v1/deals` | Create deal | `deals.create` |
| PUT | `/api/v1/deals/:id` | Update deal | `deals.edit` |
| PUT | `/api/v1/deals/:id/payment` | Update payment | `deals.update_payment` |
| GET | `/api/v1/deals/:id/payment-history` | Payment history | `deals.view` |

---

## 6. Permissions Required

| Action | Permission |
|--------|------------|
| Xem deals | `deals.view` |
| Tạo deal | `deals.create` |
| Sửa deal | `deals.edit` |
| Cập nhật thanh toán | `deals.update_payment` |

---

> **Related**: 
> - [khach-hang](../khach-hang/) - Deal được tạo từ contact
> - [san-pham](../san-pham/) - Chọn products cho deal
> - [nhat-ky-hoat-dong](../nhat-ky-hoat-dong/) - Log payment history
