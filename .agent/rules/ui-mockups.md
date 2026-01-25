---
trigger: always_on
---

# UI Development Rule

> **Version 1.0** - Rule cho tất cả các task liên quan đến giao diện

---

## MANDATORY: Sử dụng Mockups làm Base

**Tất cả các task UI/Frontend PHẢI tuân thủ quy tắc sau:**

### 1. Trước khi implement bất kỳ UI nào:
1. **CHECK** thư mục `docs/ui-design/wireframes/` để tìm mockup tương ứng
2. **ĐỌC** file HTML mockup để hiểu:
   - Layout structure
   - Color scheme & styling
   - Components được sử dụng
   - Responsive breakpoints
3. **COPY** các class CSS, color codes, và patterns từ mockup

### 2. Mapping Task → Mockup:

| Task Type | Mockup File |
|-----------|-------------|
| Login page | `wireframes/index.html` |
| Forgot password | `wireframes/forgot_password.html` |
| Reset password | `wireframes/reset_password.html` |
| Dashboard | `wireframes/dashboard.html` |
| Contacts list | `wireframes/contacts_list.html` |
| Contact form | `wireframes/contacts_form.html` |
| Contact detail | `wireframes/contact_detail.html` |
| Roles & Permissions | `wireframes/roles.html` |
| Teams | `wireframes/teams.html` |
| Employees | `wireframes/employees.html` |
| Products | `wireframes/products.html` |
| Deals | `wireframes/deals_list.html` |
| Coupons | `wireframes/coupons.html` |
| Notifications | `wireframes/notifications.html` |
| Logs | `wireframes/logs.html` |
| Reports | `wireframes/reports.html` |
| Profile | `wireframes/profile.html` |
| Zalo | `wireframes/zalo_composer.html` |

### 3. Implementation Guidelines:
- **Giữ nguyên** color palette từ mockups
- **Giữ nguyên** spacing và typography
- **Sử dụng** Tailwind classes giống như trong mockup
- **Convert** static HTML thành ERB templates
- **Thêm** Turbo/Stimulus cho interactivity

### 4. Forbidden:
- ❌ Không tự ý thay đổi màu sắc hoặc layout
- ❌ Không bỏ qua mockup mà tự thiết kế
- ❌ Không thêm elements không có trong mockup mà không hỏi

---

## Quick Reference

```
docs/ui-design/wireframes/
├── index.html              # Login
├── forgot_password.html    # Quên mật khẩu
├── reset_password.html     # Reset mật khẩu
├── dashboard.html          # Trang chủ
├── contacts_list.html      # Danh sách KH
├── contacts_form.html      # Form KH
├── contact_detail.html     # Chi tiết KH
├── roles.html              # Phân quyền
├── teams.html              # Teams
├── employees.html          # Nhân viên
└── ...
```
