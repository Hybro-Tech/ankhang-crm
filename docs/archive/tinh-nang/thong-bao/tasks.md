# 📋 Công Việc: Thông Báo

> **Module**: 05-notifications  
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
| NOTI-T001 | Cài đặt Sidekiq + Redis | [ ] | Cao | 2h | | |
| NOTI-T002 | Tạo base NotificationJob | [ ] | Cao | 1h | | |
| NOTI-T003 | Tạo interface cho channel adapter | [ ] | Cao | 1h | | |

### Cơ Sở Dữ Liệu

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| NOTI-T004 | Tạo bảng notification_rules | [ ] | Cao | 0.5h | | |
| NOTI-T005 | Tạo bảng notification_logs | [ ] | Cao | 0.5h | | |
| NOTI-T006 | Tạo bảng notification_deliveries | [ ] | Cao | 0.5h | | |

### Các Kênh Gửi Thông Báo

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| NOTI-T007 | Adapter Email (ActionMailer) | [ ] | Cao | 3h | | |
| NOTI-T008 | Adapter Slack (Webhook) | [ ] | Cao | 2h | | |
| NOTI-T009 | Adapter Web Push (gem webpush) | [ ] | Cao | 4h | | |
| NOTI-T010 | Adapter Zalo OA | [ ] | Trung | 4h | | |
| NOTI-T011 | Adapter Facebook | [ ] | Trung | 4h | | |

### Bộ Xử Lý Quy Tắc

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| NOTI-T012 | Viết bộ phân tích điều kiện quy tắc | [ ] | Cao | 4h | | |
| NOTI-T013 | Viết bộ lọc người nhận | [ ] | Cao | 3h | | |
| NOTI-T014 | Thay thế biến trong template | [ ] | Trung | 2h | | |
| NOTI-T015 | Hệ thống kích hoạt sự kiện | [ ] | Cao | 3h | | |

### API

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| NOTI-T016 | API CRUD cho quy tắc | [ ] | Cao | 3h | | |
| NOTI-T017 | API bật/tắt quy tắc | [ ] | Cao | 0.5h | | |
| NOTI-T018 | API test quy tắc | [ ] | Trung | 2h | | |
| NOTI-T019 | API lịch sử thông báo | [ ] | Trung | 2h | | |
| NOTI-T020 | API gửi thông báo thủ công | [ ] | Trung | 1h | | |

### Giao Diện

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| NOTI-T021 | Trang danh sách quy tắc | [ ] | Cao | 2h | | |
| NOTI-T022 | Giao diện tạo quy tắc | [ ] | Cao | 6h | | |
| NOTI-T023 | Component xây dựng điều kiện | [ ] | Cao | 4h | | |
| NOTI-T024 | Component chọn kênh gửi | [ ] | Cao | 1h | | |
| NOTI-T025 | Modal test quy tắc | [ ] | Trung | 2h | | |
| NOTI-T026 | Trang lịch sử thông báo | [ ] | Trung | 2h | | |

### Tối Ưu Hiệu Năng

| ID | Công việc | Trạng thái | Ưu tiên | Ước lượng | Phân công | Deadline |
|----|-----------|------------|---------|-----------|-----------|----------|
| NOTI-T027 | Gửi song song (Sidekiq workers) | [ ] | Cao | 2h | | |
| NOTI-T028 | Cơ chế thử lại khi lỗi | [ ] | Cao | 1h | | |
| NOTI-T029 | Theo dõi trạng thái gửi | [ ] | Trung | 2h | | |

---

## Ghi Chú

- ⭐ Yêu cầu hiệu năng: 100-200 users < 5 giây
- Sử dụng Sidekiq với 20 workers để xử lý song song

---

> **Tham khảo**: [requirements.md](./requirements.md)
