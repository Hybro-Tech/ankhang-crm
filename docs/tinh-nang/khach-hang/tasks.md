# 📋 Công Việc: Khách Hàng

> **Module**: 03-customers  
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
| CUST-T001 | Tạo migration bảng customers | [ ] | Cao | 0.5h | | |
| CUST-T002 | Thiết lập model Customer + validations | [ ] | Cao | 1h | | |
| CUST-T003 | Thêm enum cho status | [ ] | Cao | 0.5h | | |
| CUST-T004 | Thiết lập soft delete (gem paranoia) | [ ] | Cao | 1h | | |
| CUST-T005 | Thêm FULLTEXT index cho tìm kiếm | [ ] | Cao | 0.5h | | |

### API

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| CUST-T006 | API danh sách khách hàng (phân trang) | [ ] | Cao | 2h | | |
| CUST-T007 | API chi tiết khách hàng | [ ] | Cao | 1h | | |
| CUST-T008 | API tạo khách hàng | [ ] | Cao | 1h | | |
| CUST-T009 | API cập nhật khách hàng | [ ] | Cao | 1h | | |
| CUST-T010 | API xóa khách hàng (soft delete) | [ ] | Cao | 1h | | |
| CUST-T011 | API tìm kiếm (FULLTEXT) | [ ] | Cao | 2h | | |
| CUST-T012 | API lọc theo trạng thái | [ ] | Cao | 1h | | |
| CUST-T013 | API lịch sử thay đổi | [ ] | Trung | 2h | | |

### Giao Diện

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| CUST-T014 | Trang danh sách khách hàng | [ ] | Cao | 3h | | |
| CUST-T015 | Giao diện tìm kiếm & lọc | [ ] | Cao | 2h | | |
| CUST-T016 | Trang chi tiết khách hàng | [ ] | Cao | 2h | | |
| CUST-T017 | Form thêm/sửa khách hàng | [ ] | Cao | 2h | | |
| CUST-T018 | Dropdown trạng thái có màu sắc | [ ] | Trung | 1h | | |
| CUST-T019 | Sidebar lịch sử thay đổi | [ ] | Trung | 2h | | |
| CUST-T020 | Component phân trang | [ ] | Cao | 1h | | |

---

## Ghi Chú

- Luồng trạng thái: Tiềm năng → Đã liên hệ → Đang xử lý → Hoàn thành/Từ chối
- Xóa mềm sử dụng trường `deleted_at`

---

> **Tham khảo**: [requirements.md](./requirements.md)
