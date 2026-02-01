# Sprint 3 - Hướng dẫn Test theo Role

> **Phiên bản**: 1.0  
> **Ngày**: 2026-02-01  
> **Mục tiêu**: Test toàn bộ chức năng Sprint 3 (Pick Mechanism, Smart Routing, Real-time, Web Push, Admin Re-assign)

---

## 📋 Tài khoản Test

| Role | Email | Password | Mô tả |
|------|-------|----------|-------|
| **Super Admin** | `admin@ankhang.test` | `password123` | Full quyền, quản lý hệ thống |
| **Call Center** | `callcenter@ankhang.test` | `password123` | Tạo contact mới |
| **Sale Staff** | `sale.hn1@ankhang.test` | `password123` | Nhận và chăm sóc khách hàng |
| **Team Leader** | `sale.hn1@ankhang.test` | `password123` | Duyệt yêu cầu re-assign (user này vừa là Sale vừa là TL) |

---

## 🔴 ROLE: SUPER ADMIN

### 1. Login & Dashboard
- [ ] Login với `admin@ankhang.test`
- [ ] Verify redirect về `/` (Admin Dashboard)
- [ ] Verify Connection Status Indicator hiển thị "Trực tuyến" (góc phải header)

### 2. Smart Routing Config (TASK-053)
- [ ] Truy cập `/service_types`
- [ ] Chọn một Service Type → Edit
- [ ] Verify các field:
  - `Visibility Expand Minutes` (mặc định 2)
  - `Max Pick Per Day` (mặc định 20)
  - `Pick Cooldown Minutes` (mặc định 5)
- [ ] Thay đổi giá trị và Save
- [ ] Verify giá trị được lưu

### 3. Admin Re-assign Contact (TASK-052)
- [ ] Truy cập `/contacts`
- [ ] Click vào một Contact đã được assign cho Sale
- [ ] Click nút **"Chuyển KH"** hoặc **"Gỡ KH"**
- [ ] Verify Modal hiển thị:
  - Dropdown chọn Sale mới (chỉ filter theo Team có quyền)
  - Textarea nhập lý do (bắt buộc)
- [ ] Submit request
- [ ] Verify thông báo thành công

### 4. Xem Pending Requests (Admin View)
- [ ] Truy cập `/teams/reassign_requests`
- [ ] Verify tabs: Tất cả, Chờ duyệt, Đã xử lý
- [ ] Verify thấy request vừa tạo

### 5. Solid Queue Monitoring
- [ ] Truy cập `/solid_queue` (từ sidebar Admin > Giám sát hệ thống)
- [ ] Verify thấy job counts, charts
- [ ] Test "Retry All", "Clear Completed" buttons

### 6. Solid Cache Monitoring
- [ ] Truy cập `/solid_cache`
- [ ] Verify thấy cache entries
- [ ] Test "Clear Expired" button

### 7. Solid Cable Monitoring
- [ ] Truy cập `/solid_cable`
- [ ] Verify thấy active connections

### 8. Web Push (TASK-056)
- [ ] Click vào User Menu (góc phải)
- [ ] Click "Bật thông báo"
- [ ] Cho phép Browser Permission
- [ ] Verify text đổi thành "🔔 Tắt thông báo"

---

## 🟡 ROLE: CALL CENTER

### 1. Login & Dashboard
- [ ] Login với `callcenter@ankhang.test`
- [ ] Verify redirect về Dashboard Call Center
- [ ] Verify Connection Status "Trực tuyến"

### 2. Tạo Contact Mới
- [ ] Click "+ Thêm KH" hoặc form inline
- [ ] Nhập thông tin:
  - Họ tên: "Test Smart Routing"
  - Điện thoại: "0123456789"
  - Loại dịch vụ: Chọn một loại
- [ ] Submit

### 3. Verify Smart Routing (TASK-054)
- [ ] Sau khi tạo contact, verify:
  - Contact có `status: new_contact`
  - `visibility_level: 1` (chỉ Team chuyên môn thấy)
  - `assigned_user_id: nil` (chưa ai nhận)
- [ ] **Chờ X phút** (theo `visibility_expand_minutes` của Service Type)
- [ ] Check lại contact → `visibility_level` tăng lên 2, 3, ...
- [ ] Cuối cùng → `visibility_level: pool` (tất cả Sale thấy)

### 4. Real-time Update Test (TASK-055)
- [ ] Mở 2 tab browser: Call Center + Sale
- [ ] Từ tab Call Center: tạo contact mới
- [ ] Verify tab Sale thấy contact xuất hiện real-time (không cần refresh)

---

## 🟢 ROLE: SALE STAFF

### 1. Login & Workspace
- [ ] Login với `sale.hn1@ankhang.test`
- [ ] **Verify redirect về `/sales/workspace`** (KHÔNG phải `/`)
- [ ] Verify header hiển thị "Chào Phạm, hôm nay có X việc cần làm"
- [ ] Verify Connection Status "Trực tuyến" (góc phải)

### 2. Pick Mechanism (TASK-022)
- [ ] Tab "Khách mới" hiển thị contacts chưa ai nhận
- [ ] Click nút **"NHẬN"** trên một contact
- [ ] Verify:
  - Contact chuyển sang "Đang chăm sóc" 
  - Nút "NHẬN" biến mất cho user khác (test với 2 browser)
  - Toast/Flash message hiển thị "Đã nhận khách hàng"

### 3. Pick Rules Test (TASK-022b)
- [ ] Thử pick liên tục nhiều contact
- [ ] Verify cooldown: Sau khi pick, phải chờ X phút mới pick tiếp (theo ServiceType config)
- [ ] Verify daily limit: Sau khi pick đủ số lượng/ngày → hiển thị lỗi

### 4. Chi tiết Contact (TASK-023)
- [ ] Click vào một contact trong danh sách
- [ ] Verify Slide-over panel mở ra với:
  - Thông tin khách hàng (tên, SĐT, email, nguồn...)
  - Timeline lịch sử chăm sóc
  - Form thêm ghi chú mới
- [ ] Thêm một ghi chú → Verify xuất hiện trong timeline

### 5. Status Flow (TASK-051)
- [ ] Trong chi tiết contact, chọn dropdown "Trạng thái"
- [ ] Verify chỉ hiển thị các trạng thái hợp lệ:
  - từ `potential` → `in_progress`, `failed`
  - từ `in_progress` → `closed_new`, `failed`
- [ ] Chuyển trạng thái → Verify log được ghi

### 6. Tab "Yêu cầu duyệt" (Nếu là Team Leader)
- [ ] Verify tab "Yêu cầu duyệt" hiển thị với badge số
- [ ] Click vào tab
- [ ] Verify thấy danh sách pending requests
- [ ] Test **Duyệt**:
  - Click "Duyệt" → Xác nhận
  - Verify contact được chuyển cho người mới
- [ ] Test **Từ chối**:
  - Click "Từ chối" → Modal yêu cầu nhập lý do
  - Nhập lý do → Submit
  - Verify request bị reject

### 7. Sidebar "Yêu cầu chờ duyệt" (Team Leader)
- [ ] Verify link "Yêu cầu chờ duyệt" hiển thị trong sidebar (section Kinh doanh)
- [ ] Click vào → truy cập `/teams/reassign_requests`
- [ ] Verify NO 403 error (đã fix authorization)

### 8. Real-time Notifications (TASK-035)
- [ ] Mở 2 browser: Admin + Sale
- [ ] Từ Admin: tạo request re-assign contact của Sale này
- [ ] Verify Sale nhận notification real-time (badge đỏ tăng)
- [ ] Click notification dropdown
- [ ] Verify thấy notification mới nhất

### 9. Web Push Test (TASK-032)
- [ ] Bật thông báo từ User Menu
- [ ] Đóng tab browser (hoặc minimize)
- [ ] Từ máy khác/browser khác: tạo contact mới visible cho Sale này
- [ ] Verify Web Push notification hiển thị trên desktop
- [ ] Click notification → Verify mở đúng trang

---

## 🧪 CROSS-ROLE TESTS

### 1. Concurrency Test (Pick Race Condition)
- [ ] Mở 2 browser với 2 Sale user khác nhau
- [ ] Cùng lúc click "NHẬN" trên cùng 1 contact
- [ ] Verify chỉ 1 người nhận được, người kia thấy lỗi "Khách hàng đã được nhận"

### 2. Re-assign Approval Workflow
1. **Admin**: Tạo request chuyển contact từ Sale A sang Sale B
2. **Team Leader**: Nhận notification, duyệt request  
3. **Sale A**: Verify contact biến mất khỏi danh sách
4. **Sale B**: Verify contact xuất hiện trong danh sách
5. **Tất cả**: Nhận notification về kết quả

### 3. Unassign to Pool Workflow
1. **Admin**: Tạo request "Gỡ KH" (unassign to pool)
2. **Team Leader**: Duyệt
3. **Verify**: Contact quay lại pool, tất cả Sale thấy

### 4. Connection Status Test
- [ ] Disconnect internet (tắt WiFi)
- [ ] Verify indicator đổi thành 🔴 "Mất kết nối"
- [ ] Reconnect internet
- [ ] Verify indicator đổi lại 🟢 "Trực tuyến"

---

## 📊 Checklist Summary

| Feature | Admin | Call Center | Sale | Team Leader |
|---------|-------|-------------|------|-------------|
| Connection Status | ✅ | ✅ | ✅ | ✅ |
| Smart Routing Config | ✅ | ❌ | ❌ | ❌ |
| Create Contact | ✅ | ✅ | ❌ | ❌ |
| Pick Contact | ❌ | ❌ | ✅ | ✅ |
| Pick Rules | ❌ | ❌ | ✅ | ✅ |
| Contact Detail | ✅ | ✅ | ✅ | ✅ |
| Status Transition | ❌ | ❌ | ✅ | ✅ |
| Re-assign Request | ✅ | ❌ | ❌ | ❌ |
| Approve/Reject Request | ❌ | ❌ | ❌ | ✅ |
| Real-time Notifications | ✅ | ✅ | ✅ | ✅ |
| Web Push | ✅ | ✅ | ✅ | ✅ |
| Solid Monitoring | ✅ | ❌ | ❌ | ❌ |
| Login Redirect to Workspace | ❌ | ❌ | ✅ | ✅ |

---

## 🔧 Troubleshooting

### Web Push không hoạt động
1. Check browser hỗ trợ (Chrome, Firefox, Edge)
2. Check HTTPS hoặc localhost
3. Check Service Worker registered: DevTools → Application → Service Workers
4. Check Push Subscription saved: Rails console → `PushSubscription.last`

### Real-time không cập nhật
1. Check ActionCable connected: DevTools → Console → tìm "WebSocket"
2. Check Solid Cable running: `/solid_cable` dashboard
3. Reload page nếu connection bị mất

### Pick bị lỗi
1. Check cooldown: Chờ X phút giữa các lần pick
2. Check daily limit: Reset vào ngày mới
3. Check visibility: Contact phải visible cho user đó

---

## 📝 Notes

- Tất cả password mặc định: `password123`
- Nếu account bị lock, chạy: `rails runner "User.find_by(email: 'xxx').unlock_access!"`
- Để reset password: `rails runner "User.find_by(email: 'xxx').update(password: 'password123')"`
