# 📋 LawCRM - Tổng Quan Dự Án

> **Phiên bản**: 2.0  
> **Ngày cập nhật**: 2026-01-19  
> **Trạng thái**: Confirmed

---

## 1. Giới Thiệu

**LawCRM** là hệ thống quản lý khách hàng (CRM) được thiết kế cho doanh nghiệp cung cấp dịch vụ luật, nhằm chuyển đổi số quy trình làm việc từ Google Sheets sang nền tảng phần mềm chuyên nghiệp.

### 1.1 Vấn Đề Cần Giải Quyết

- Dữ liệu phân tán trên nhiều Google Sheets
- Khó theo dõi và tìm kiếm thông tin liên hệ
- Không có hệ thống thông báo tự động khi có lead mới
- Không có audit trail / lịch sử hoạt động
- Phân quyền thủ công, khó quản lý
- Không có cơ chế cạnh tranh pick contact cho Sales

### 1.2 Giải Pháp

Xây dựng hệ thống CRM tập trung với:
- Quản lý **Contacts/Leads** chuyên nghiệp
- Cơ chế **pick contact** cạnh tranh cho Sales
- **Chăm sóc multi-layer** cho CSKH
- Phân quyền động (dynamic permissions)
- Thông báo đa kênh thông minh (Web Push, Email, Zalo OA)
- Audit trail đầy đủ
- Dashboard và báo cáo

---

## 2. Mục Tiêu

| # | Mục tiêu | Đo lường |
|---|----------|----------|
| 1 | Chuyển đổi số hoàn toàn | 100% dữ liệu trên hệ thống mới |
| 2 | Thông báo không trễ | < 5 giây cho 100-200 users |
| 3 | Dễ sử dụng | Training < 1 ngày |
| 4 | Bảo mật | Audit trail 100% actions |
| 5 | Tăng hiệu suất Sales | Cơ chế pick contact công bằng |

---

## 3. Đối Tượng Sử Dụng

| Vai trò | Mô tả | Số lượng |
|---------|-------|----------|
| **Super Admin** | Quản trị toàn bộ hệ thống | 2-3 |
| **Tổng Đài** | Nhận điện thoại, tạo contacts | 5-10 |
| **Sale** | Pick contact, tư vấn, chốt deal | 50-80 |
| **CSKH** | Chăm sóc lại contacts fail | 5-10 |
| **Tổng cộng** | | ~100 users |

---

## 4. Phạm Vi Dự Án

### 4.1 ✅ Phase 1 (MVP+)

| Module | Tính năng chính |
|--------|-----------------|
| Authentication | Login, logout, forgot password |
| Permissions | Dynamic roles + per-user override |
| Teams | Quản lý teams |
| Contacts | CRUD, pick, search, filter, interaction history |
| Deals | Thông tin chốt deal, thanh toán |
| Products | Quản lý dịch vụ/hợp đồng |
| Employees | CRUD, role/team assignment |
| Notifications | Web Push, Email, Zalo OA + custom rules |
| Logs | Full audit trail, status/payment history |
| Reports | Dashboard cơ bản |

### 4.2 ⏳ Phase 2 (Future)

| Tính năng | Mô tả |
|-----------|-------|
| Import Google Sheets | Migrate dữ liệu cũ |
| 2FA Authentication | Bảo mật 2 lớp |
| Real-time (WebSocket) | Notifications real-time |
| Advanced Reports | Export, scheduled reports |
| Multi-layer CSKH | L3, L4... rotation |

### 4.3 ❌ Ngoài Phạm Vi

- Mobile app native (iOS/Android)
- Tích hợp cổng thanh toán (chỉ tracking status)
- AI/ML features phức tạp (chỉ sentiment analysis đơn giản)

---

## 5. Tech Stack

| Layer | Technology | Lý do |
|-------|------------|-------|
| **Backend** | Ruby on Rails 7+ | Client requirement, rapid dev |
| **Frontend** | HTML, CSS, JS | Client requirement |
| **CSS Framework** | TailwindCSS / Bootstrap 5 | Modern, responsive |
| **JS Framework** | Hotwire (Turbo + Stimulus) | Rails-native |
| **Database** | MySQL 8+ | Client requirement |
| **Search** | MySQL FULLTEXT | Simple, integrated |
| **Cache** | Redis | Sessions, queues |
| **Jobs** | Sidekiq | Background processing |
| **Hosting** | AWS / VPS | Client requirement |

---

## 6. Cấu Trúc Tài Liệu

| Folder | Nội dung |
|--------|----------|
| [00-overview](./00-overview/) | File này - tổng quan |
| [01-authentication](./01-authentication/) | Module xác thực |
| [02-permissions](./02-permissions/) | Module phân quyền ⭐ |
| [03-contacts](./03-contacts/) | Module contacts/leads ⭐ |
| [04-employees](./04-employees/) | Module nhân viên |
| [05-notifications](./05-notifications/) | Module thông báo ⭐ |
| [06-logs](./06-logs/) | Module audit logs |
| [07-reports](./07-reports/) | Module báo cáo |
| [08-database](./08-database/) | Database schema |
| [09-phases](./09-phases/) | Timeline & phases |
| [10-products](./10-products/) | Module sản phẩm/dịch vụ 🆕 |
| [11-teams](./11-teams/) | Module teams 🆕 |
| [12-deals](./12-deals/) | Module deals 🆕 |

---

## 7. Conventions

### 7.1 ID Format

| Prefix | Module | Ví dụ |
|--------|--------|-------|
| AUTH | Authentication | AUTH-001 |
| PERM | Permissions | PERM-001 |
| CONT | Contacts | CONT-001 |
| EMP | Employees | EMP-001 |
| NOTI | Notifications | NOTI-001 |
| LOG | Logs | LOG-001 |
| RPT | Reports | RPT-001 |
| PROD | Products | PROD-001 |
| TEAM | Teams | TEAM-001 |
| DEAL | Deals | DEAL-001 |
| US | User Story | US-001 |

### 7.2 Priority Levels

| Level | Meaning |
|-------|---------|
| **Cao** | Must have, blocker nếu thiếu |
| **Trung** | Should have, quan trọng |
| **Thấp** | Nice to have, có thể delay |

---

> **Next**: Xem chi tiết từng module trong các folder tương ứng.
