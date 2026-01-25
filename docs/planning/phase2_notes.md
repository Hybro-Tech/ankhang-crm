# Phase 2 - Notes & Future Features

> **Tài liệu này lưu trữ thông tin về các tính năng sẽ triển khai trong Phase 2.**  
> **Tham khảo:** SRS v1.0, Section "Phạm vi Phase 2"

---

## 1. Modules Phase 2

### 1.1 Deals (Cơ hội bán hàng)
- Quản lý cơ hội bán hàng khi Sale chốt được với khách
- Liên kết Contact → Deal
- Theo dõi trạng thái thanh toán

**Tables cần tạo:**
- `deals` - Thông tin deal
- `deal_products` - Sản phẩm trong deal
- `payment_history` - Lịch sử thanh toán

### 1.2 Products (Sản phẩm)
- Quản lý danh sách sản phẩm/dịch vụ
- Giá cơ bản, mô tả

**Tables cần tạo:**
- `products`

### 1.3 Coupons (Khuyến mãi)
- Mã giảm giá
- Áp dụng cho Deal

**Tables cần tạo:**
- `coupons`

---

## 2. Permissions Phase 2

Thêm vào `db/seeds.rb` khi triển khai Phase 2:

```ruby
# Products & Coupons
{ code: 'products.view', name: 'Xem Sản phẩm', category: 'Products', description: 'Xem danh sách sản phẩm' },
{ code: 'products.manage', name: 'Quản lý Sản phẩm', category: 'Products', description: 'Quản lý sản phẩm' },
{ code: 'coupons.view', name: 'Xem Coupon', category: 'Coupons', description: 'Xem danh sách mã giảm giá' },
{ code: 'coupons.manage', name: 'Quản lý Coupon', category: 'Coupons', description: 'Quản lý mã giảm giá' },

# Deals
{ code: 'deals.view', name: 'Xem Deal', category: 'Deals', description: 'Xem danh sách deal' },
{ code: 'deals.create', name: 'Tạo Deal', category: 'Deals', description: 'Tạo deal' },
{ code: 'deals.edit', name: 'Sửa Deal', category: 'Deals', description: 'Sửa deal' },
{ code: 'deals.update_payment', name: 'Cập nhật Thanh toán', category: 'Deals', description: 'Cập nhật thanh toán' },
```

**Sale permissions bổ sung:**
```ruby
deals.view deals.create deals.edit deals.update_payment
```

---

## 3. UI Phase 2

Uncomment trong `app/views/shared/_sidebar.html.erb`:

```erb
<%= sidebar_link "Cơ hội bán hàng", "#", "fa-hand-holding-dollar" %>
<%= sidebar_link "Sản phẩm", "#", "fa-box-open" %>
<%= sidebar_link "Khuyến mãi", "#", "fa-ticket" %>
```

---

## 4. Tài liệu Wireframes Phase 2

Các wireframe sẵn có trong `docs/ui-design/wireframes/`:
- (Cần bổ sung khi triển khai)

---

## 5. Tài liệu chi tiết Phase 2

Xem thêm:
- `docs/tinh-nang/co-hoi-ban-hang/` - Chi tiết Deals module
- `docs/tinh-nang/san-pham/` - Chi tiết Products module

---

> **Ngày tạo:** 2026-01-25  
> **Cập nhật lần cuối:** 2026-01-25
