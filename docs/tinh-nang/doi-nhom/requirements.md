# 👥 Module: Teams

> **Module ID**: TEAM  
> **Priority**: Cao  
> **Phase**: 1

---

## 1. Tổng Quan

Module quản lý các team trong tổ chức. Teams được **phân vùng** để dễ thống kê chỉ số (Team Hà Nội, Team HCM, Team thực tập...). Mỗi nhân viên (Sale/CSKH) thuộc về 1 team.

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| TEAM-001 | Admin tạo/sửa/xóa teams | Cao | 1 |
| TEAM-002 | Gán nhân viên vào team | Cao | 1 |
| TEAM-003 | Xem danh sách teams | Cao | 1 |
| TEAM-004 | Chỉ định trưởng team | Trung | 1 |
| TEAM-005 | Thống kê theo team | Cao | 1 |

---

## 3. Thông Tin Team

### 3.1 Fields

| Field | Type | Required | Ghi chú |
|-------|------|----------|---------|
| id | int | Auto | PK |
| name | string(100) | ✅ | Tên team (vd: Team Hà Nội, Team HCM) |
| description | text | | Mô tả |
| manager_id | int | | FK users (Trưởng team) |
| region | string | | Vùng/khu vực (optional) |
| created_at | datetime | Auto | |
| updated_at | datetime | Auto | |

### 3.2 Ví Dụ Teams

| Tên | Mô tả |
|-----|-------|
| Team Hà Nội | Nhân viên khu vực Hà Nội |
| Team HCM | Nhân viên khu vực HCM |
| Team Thực Tập | Nhân viên thực tập |

---

## 5. API Endpoints

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/teams` | List teams | `teams.view` |
| GET | `/api/v1/teams/:id` | Team detail | `teams.view` |
| POST | `/api/v1/teams` | Create team | `teams.manage` |
| PUT | `/api/v1/teams/:id` | Update team | `teams.manage` |
| DELETE | `/api/v1/teams/:id` | Delete team | `teams.manage` |
| GET | `/api/v1/teams/:id/members` | List team members | `teams.view` |

---

## 6. Permissions Required

| Action | Permission |
|--------|------------|
| Xem teams | `teams.view` |
| Quản lý teams | `teams.manage` |

---

> **Related**: 
> - [nhan-vien](../nhan-vien/) - Gán user vào team
> - [khach-hang](../khach-hang/) - Contact thuộc team
