# 📋 Công Việc: Phân Quyền

> **Module**: 02-permissions  
> **Cập nhật**: 2026-01-18

---

## Lịch Sử Thay Đổi

| Ngày | Thay đổi | Người thực hiện |
|------|----------|-----------------|
| 2026-01-18 | Tạo danh sách công việc | Antigravity |

---

## Danh Sách Công Việc

### Cơ Sở Dữ Liệu & Models

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| PERM-T001 | Tạo migration bảng roles | [ ] | Cao | 0.5h | | |
| PERM-T002 | Tạo bảng permissions + seed data | [ ] | Cao | 1h | | |
| PERM-T003 | Tạo bảng liên kết role_permissions | [ ] | Cao | 0.5h | | |
| PERM-T004 | Tạo bảng liên kết user_roles | [ ] | Cao | 0.5h | | |
| PERM-T005 | Tạo bảng user_permission_overrides | [ ] | Cao | 0.5h | | |
| PERM-T006 | Thiết lập quan hệ giữa các models | [ ] | Cao | 1h | | |

### Logic Nghiệp Vụ

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| PERM-T007 | Viết method `user_has_permission?` | [ ] | Cao | 2h | | |
| PERM-T008 | Tạo authorization concern | [ ] | Cao | 2h | | |
| PERM-T009 | Thêm before_action filter cho controllers | [ ] | Cao | 1h | | |

### API

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| PERM-T010 | API CRUD cho Roles | [ ] | Cao | 3h | | |
| PERM-T011 | API danh sách Permissions | [ ] | Cao | 1h | | |
| PERM-T012 | API gán roles cho user | [ ] | Cao | 2h | | |
| PERM-T013 | API override permissions | [ ] | Cao | 2h | | |
| PERM-T014 | API clone role | [ ] | Trung | 1h | | |

### Giao Diện

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| PERM-T015 | Trang danh sách Roles | [ ] | Cao | 2h | | |
| PERM-T016 | Form tạo/sửa Role | [ ] | Cao | 3h | | |
| PERM-T017 | Giao diện ma trận Permission | [ ] | Cao | 4h | | |
| PERM-T018 | Giao diện override permission cho user | [ ] | Cao | 3h | | |

---

## Ghi Chú

- ⭐ Module quan trọng nhất - cần test kỹ
- Thứ tự ưu tiên: User override > Role permissions

---

> **Tham khảo**: [requirements.md](./requirements.md)
