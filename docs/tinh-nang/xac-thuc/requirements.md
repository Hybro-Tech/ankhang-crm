# 🔐 Module: Authentication

> **Module ID**: AUTH  
> **Priority**: Cao  
> **Phase**: 1

---

## 1. Tổng Quan

Module xác thực người dùng, quản lý session và bảo mật tài khoản.

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| AUTH-001 | Đăng nhập bằng username/password | Cao | 1 |
| AUTH-002 | Remember me (session kéo dài) | Cao | 1 |
| AUTH-003 | Forgot password qua email | Cao | 1 |
| AUTH-004 | Đổi mật khẩu | Cao | 1 |
| AUTH-005 | Đăng xuất | Cao | 1 |
| AUTH-006 | Session timeout (auto logout) | Trung | 1 |
| AUTH-007 | 2FA Authentication | Trung | 2 |

---

## 3. User Stories

| ID | Vai trò | Mong muốn | Để | Priority |
|----|---------|-----------|-----|----------|
| US-001 | Nhân viên | Đăng nhập bằng username/password | Truy cập hệ thống | Cao |
| US-002 | Nhân viên | Tick "Remember me" | Không phải đăng nhập lại mỗi ngày | Cao |
| US-003 | Nhân viên | Nhận email reset password | Khôi phục tài khoản khi quên | Cao |
| US-004 | Nhân viên | Đổi mật khẩu trong settings | Bảo mật tài khoản | Cao |
| US-005 | Nhân viên | Đăng xuất an toàn | Bảo vệ khi rời máy tính | Cao |

---

## 4. Acceptance Criteria

### AC-001: Đăng nhập

**Given**: Tôi đang ở trang login  
**When**: Nhập đúng username/password và click Login  
**Then**:
- [ ] Chuyển đến Dashboard
- [ ] Hiển thị tên user ở header
- [ ] Session được tạo (cookie)

**When**: Nhập sai thông tin  
**Then**:
- [ ] Hiện thông báo lỗi "Sai username hoặc password"
- [ ] Không chuyển trang
- [ ] Ghi log failed attempt

### AC-003: Forgot Password

**Given**: Tôi ở trang forgot password  
**When**: Nhập email hợp lệ và submit  
**Then**:
- [ ] Gửi email chứa link reset (expires 1h)
- [ ] Hiện thông báo "Đã gửi email"
- [ ] Link chỉ dùng được 1 lần

---

## 5. UI/UX Notes

### Login Page

```
┌─────────────────────────────────────────┐
│                                         │
│          🏛️ LawCRM                      │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ Username                        │   │
│   └─────────────────────────────────┘   │
│   ┌─────────────────────────────────┐   │
│   │ Password                    👁️  │   │
│   └─────────────────────────────────┘   │
│                                         │
│   [✓] Remember me                       │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │         🔐 Đăng nhập            │   │
│   └─────────────────────────────────┘   │
│                                         │
│          Quên mật khẩu?                 │
│                                         │
└─────────────────────────────────────────┘
```

---

## 6. API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/v1/auth/login` | Đăng nhập | No |
| POST | `/api/v1/auth/logout` | Đăng xuất | Yes |
| POST | `/api/v1/auth/forgot-password` | Gửi email reset | No |
| POST | `/api/v1/auth/reset-password` | Đặt password mới | No (token) |
| PUT | `/api/v1/auth/change-password` | Đổi password | Yes |

### Request/Response Examples

**POST /api/v1/auth/login**

Request:
```json
{
  "username": "nguyen.van.a",
  "password": "********",
  "remember_me": true
}
```

Response (Success):
```json
{
  "success": true,
  "user": {
    "id": 1,
    "username": "nguyen.van.a",
    "name": "Nguyễn Văn A",
    "roles": ["Sales"]
  },
  "redirect_to": "/dashboard"
}
```

Response (Error):
```json
{
  "success": false,
  "error": "Sai username hoặc password"
}
```

---

## 7. Security Requirements

| Yêu cầu | Implementation |
|---------|----------------|
| Password hashing | bcrypt (cost 12) |
| Min password length | 8 characters |
| Session storage | Redis (encrypted) |
| Session timeout | **3 ngày (72h)** ✅ Confirmed |
| Remember me | 30 days |
| HTTPS only | Secure cookies |
| Brute force protection | Rate limiting (5 attempts/min) |

---

## 8. Database Tables

### sessions (managed by Rails)

| Column | Type | Description |
|--------|------|-------------|
| id | bigint | PK |
| user_id | int | FK to users |
| session_token | string | Hashed token |
| ip_address | string | |
| user_agent | string | |
| expires_at | datetime | |
| created_at | datetime | |

---

> **Related**: [02-permissions.md](./02-permissions.md) cho phân quyền sau khi login
