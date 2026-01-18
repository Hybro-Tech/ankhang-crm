# 📋 Công Việc: Nhật Ký Hoạt Động

> **Module**: 06-logs  
> **Cập nhật**: 2026-01-18

---

## Lịch Sử Thay Đổi

| Ngày | Thay đổi | Người thực hiện |
|------|----------|-----------------|
| 2026-01-18 | Tạo danh sách công việc | Antigravity |

---

## Danh Sách Công Việc

### Cơ Sở Dữ Liệu

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| LOG-T001 | Tạo bảng activity_logs | [ ] | Cao | 0.5h | | |
| LOG-T002 | Thiết lập indexes (FULLTEXT, created_at) | [ ] | Cao | 0.5h | | |
| LOG-T003 | Thiết lập phân vùng theo tháng | [ ] | Trung | 2h | | |

### Logic Nghiệp Vụ

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| LOG-T004 | Tạo concern Auditable | [ ] | Cao | 2h | | |
| LOG-T005 | Include Auditable vào tất cả models | [ ] | Cao | 0.5h | | |
| LOG-T006 | Theo dõi thay đổi (trước/sau) | [ ] | Cao | 1h | | |
| LOG-T007 | Lưu IP + User Agent | [ ] | Cao | 1h | | |

### API

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| LOG-T008 | API danh sách logs (phân trang) | [ ] | Cao | 2h | | |
| LOG-T009 | API chi tiết log | [ ] | Cao | 1h | | |
| LOG-T010 | API lọc theo user/action/ngày | [ ] | Cao | 2h | | |
| LOG-T011 | API tìm kiếm (FULLTEXT) | [ ] | Cao | 1h | | |
| LOG-T012 | API logs của tôi (quyền view_own) | [ ] | Trung | 1h | | |

### Giao Diện

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| LOG-T013 | Trang danh sách logs | [ ] | Cao | 2h | | |
| LOG-T014 | Thanh lọc | [ ] | Cao | 2h | | |
| LOG-T015 | Modal chi tiết (xem diff) | [ ] | Trung | 2h | | |
| LOG-T016 | Component chọn khoảng ngày | [ ] | Trung | 1h | | |

### Tối Ưu

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| LOG-T017 | Job lưu trữ logs cũ | [ ] | Trung | 2h | | |
| LOG-T018 | Job dọn dẹp logs rất cũ | [ ] | Thấp | 1h | | |

---

## Ghi Chú

- Sử dụng FULLTEXT search cho tìm kiếm
- Phân vùng theo tháng để tối ưu hiệu năng truy vấn

---

> **Tham khảo**: [requirements.md](./requirements.md)
