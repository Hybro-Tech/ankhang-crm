# 📋 Công Việc: Thiết Lập Cơ Sở Dữ Liệu

> **Module**: 08-database  
> **Cập nhật**: 2026-01-18

---

## Lịch Sử Thay Đổi

| Ngày | Thay đổi | Người thực hiện |
|------|----------|-----------------|
| 2026-01-18 | Tạo danh sách công việc | Antigravity |

---

## Danh Sách Công Việc

### Cơ Sở Hạ Tầng

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| DB-T001 | Cài đặt MySQL 8 với Docker | [ ] | Cao | 1h | | |
| DB-T002 | Cài đặt Redis với Docker | [ ] | Cao | 0.5h | | |
| DB-T003 | Tạo file docker-compose.yml | [ ] | Cao | 1h | | |
| DB-T004 | Cấu hình database.yml | [ ] | Cao | 0.5h | | |

### Migrations

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| DB-T005 | Tạo bảng users | [ ] | Cao | 0.5h | | |
| DB-T006 | Tạo bảng roles | [ ] | Cao | 0.5h | | |
| DB-T007 | Tạo bảng permissions | [ ] | Cao | 0.5h | | |
| DB-T008 | Tạo bảng role_permissions | [ ] | Cao | 0.5h | | |
| DB-T009 | Tạo bảng user_roles | [ ] | Cao | 0.5h | | |
| DB-T010 | Tạo bảng user_permission_overrides | [ ] | Cao | 0.5h | | |
| DB-T011 | Tạo bảng customers | [ ] | Cao | 0.5h | | |
| DB-T012 | Tạo bảng activity_logs | [ ] | Cao | 0.5h | | |
| DB-T013 | Tạo bảng notification_rules | [ ] | Cao | 0.5h | | |
| DB-T014 | Tạo bảng notification_logs | [ ] | Cao | 0.5h | | |
| DB-T015 | Tạo bảng notification_deliveries | [ ] | Cao | 0.5h | | |

### Dữ Liệu Mẫu

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| DB-T016 | Seed dữ liệu permissions | [ ] | Cao | 1h | | |
| DB-T017 | Seed roles mặc định (Admin, Manager, Sales) | [ ] | Cao | 0.5h | | |
| DB-T018 | Seed tài khoản admin | [ ] | Cao | 0.5h | | |
| DB-T019 | Seed dữ liệu mẫu (chỉ dev) | [ ] | Thấp | 2h | | |

### Tối Ưu

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| DB-T020 | Thêm tất cả indexes | [ ] | Cao | 1h | | |
| DB-T021 | Thiết lập phân vùng cho activity_logs | [ ] | Trung | 1h | | |

---

## Ghi Chú

- MySQL 8 với charset utf8mb4
- Redis cho sessions + cache + hàng đợi Sidekiq

---

> **Tham khảo**: [requirements.md](./requirements.md)
