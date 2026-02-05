# 📦 Module: Products

> **Module ID**: PROD  
> **Priority**: Cao  
> **Phase**: 1

---

## 1. Tổng Quan

Module quản lý danh sách sản phẩm/dịch vụ mà doanh nghiệp cung cấp. Mỗi sản phẩm có thể có quy trình triển khai (workflow) và các fields khác nhau.

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| PROD-001 | Admin tạo/sửa/xóa products | Cao | 1 |
| PROD-002 | Xem danh sách products | Cao | 1 |
| PROD-003 | Mỗi product có workflow riêng | Cao | 1 |
| PROD-004 | Kích hoạt/vô hiệu hóa product | Trung | 1 |
| PROD-005 | Custom fields theo từng product | Trung | 2 |

---

## 3. Thông Tin Product

### 3.1 Fields

| Field | Type | Required | Ghi chú |
|-------|------|----------|---------|
| id | int | Auto | PK |
| code | string(20) | ✅ | Mã SP (vd: TLDN-7, DVK-25, KTDN) |
| name | string(255) | ✅ | Tên dịch vụ |
| description | text | | Mô tả |
| base_price | decimal | | Giá cơ bản |
| workflow_type | string | | Loại quy trình triển khai |
| custom_fields | json | | Các fields tùy biến theo SP |
| is_active | boolean | ✅ | Đang kinh doanh |
| created_at | datetime | Auto | |
| updated_at | datetime | Auto | |

### 3.2 Ví Dụ Products (Từ hệ thống hiện tại)

| Code | Tên | Loại |
|------|-----|------|
| TLDN-7 | TLDN Gói Nâng Cao | Thành lập DN |
| TLDN-6 | Gói Kỳ Lân 2026 | Thành lập DN |
| TLDN-5 | Gói VIP 2026 | Thành lập DN |
| TKLG3 | Thiết kế Logo - Gói Vàng | Thiết kế |
| DVK-25 | Dịch vụ khác | Khác |
| DVK-24 | Thông báo phát hành hóa đơn | Dịch vụ |
| KTDN | Kế toán lẻ | Kế toán |

> [!NOTE]
> Mỗi loại SP có thể có quy trình follow/triển khai khác nhau. Phase 2 sẽ hỗ trợ custom fields cho từng loại SP.

---

## 5. API Endpoints

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/products` | List products | `products.view` |
| GET | `/api/v1/products/:id` | Product detail | `products.view` |
| POST | `/api/v1/products` | Create product | `products.manage` |
| PUT | `/api/v1/products/:id` | Update product | `products.manage` |
| DELETE | `/api/v1/products/:id` | Delete product | `products.manage` |
| GET | `/api/v1/coupons` | List coupons | `coupons.view` |
| POST | `/api/v1/coupons` | Create coupon | `coupons.manage` |

---

## 6. Permissions Required

| Action | Permission |
|--------|------------|
| Xem products | `products.view` |
| Quản lý products | `products.manage` |
| Xem coupons | `coupons.view` |
| Quản lý coupons | `coupons.manage` |

---

> **Related**: 
> - [co-hoi-ban-hang](../co-hoi-ban-hang/) - Chọn product khi chốt deal
