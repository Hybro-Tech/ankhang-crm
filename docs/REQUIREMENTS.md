# 📋 LawCRM - Tổng Hợp Yêu Cầu Hệ Thống

> **Phiên bản**: 2.0  
> **Ngày cập nhật**: 2026-01-19  
> **Trạng thái**: Confirmed

---

## 1. Giới Thiệu

**LawCRM** là hệ thống quản lý khách hàng (CRM) cho doanh nghiệp dịch vụ luật, chuyển đổi số từ Google Sheets sang nền tảng chuyên nghiệp.

### 1.1 Mục Tiêu Chính
- ✅ Chuyển đổi số 100% từ Google Sheets
- ✅ Thông báo real-time khi có contact mới
- ✅ Cơ chế pick contact công bằng cho Sales
- ✅ Multi-layer CSKH chăm sóc contacts fail
- ✅ Audit trail đầy đủ

---

## 2. Kiến Trúc Hệ Thống

```mermaid
flowchart TB
    subgraph Users["👥 Users"]
        SA[Super Admin]
        TD[Tổng Đài]
        SL[Sales]
        CS[CSKH]
    end
    
    subgraph Frontend["🖥️ Frontend"]
        WEB[Web App<br/>Hotwire/Turbo]
    end
    
    subgraph Backend["⚙️ Backend"]
        RAILS[Ruby on Rails 7+]
        SIDEKIQ[Sidekiq<br/>Background Jobs]
    end
    
    subgraph Storage["💾 Storage"]
        MYSQL[(MySQL 8+)]
        REDIS[(Redis<br/>Cache/Queue)]
    end
    
    subgraph External["🌐 External"]
        ZALO[Zalo OA]
        EMAIL[Email SMTP]
        AI[AI Sentiment]
    end
    
    Users --> WEB
    WEB --> RAILS
    RAILS --> MYSQL
    RAILS --> REDIS
    RAILS --> SIDEKIQ
    SIDEKIQ --> ZALO
    SIDEKIQ --> EMAIL
    SIDEKIQ --> AI
```

---

## 3. Vai Trò & Phân Quyền

```mermaid
flowchart LR
    subgraph Roles["Vai Trò"]
        SA["🔑 Super Admin<br/>Toàn quyền"]
        TD["📞 Tổng Đài<br/>Tạo contacts"]
        SL["💼 Sale<br/>Pick & chốt"]
        CS["💬 CSKH<br/>Chăm sóc fail"]
    end
    
    SA --> |quản lý| TD
    SA --> |quản lý| SL
    SA --> |quản lý| CS
```

| Vai trò | Quyền chính |
|---------|-------------|
| **Super Admin** | Quản lý users, teams, products, coupons, settings |
| **Tổng Đài** | Tạo contacts, phân loại nguồn |
| **Sale** | Pick contact, trao đổi, chốt deal |
| **CSKH** | Xem contacts fail, gửi Zalo, chăm sóc lại |

---

## 4. Luồng Hoạt Động Chính

```mermaid
flowchart TD
    START([Khách gọi điện]) --> TD[Tổng Đài nhận]
    TD --> CREATE[Tạo Contact mới]
    CREATE --> NOTI[🔔 Bắn Notification<br/>đến tất cả Sales]
    
    NOTI --> PICK{Sales Pick}
    PICK --> |5p/lần| PICKED[Contact được gán cho Sale]
    
    PICKED --> WORK[Sale trao đổi, tư vấn]
    WORK --> RESULT{Kết quả?}
    
    RESULT --> |Thành công| CHOT[✅ CHỐT<br/>Tạo Deal]
    RESULT --> |Thất bại| FAIL[❌ FAIL<br/>Chuyển CSKH]
    
    CHOT --> DEAL[Nhập SP, giá, thanh toán]
    
    FAIL --> CSKH[CSKH chăm sóc]
    CSKH --> ZALO[Gửi Zalo định kỳ]
    ZALO --> AI{AI phân tích}
    AI --> |Tích cực| IGNORE[Bỏ qua]
    AI --> |Tiêu cực| NOTI_CS[🔔 Noti cho CSKH]
    NOTI_CS --> CSKH
    
    CSKH --> RESULT2{Kết quả?}
    RESULT2 --> |Thành công| CHOT
    RESULT2 --> |Thất bại| CLOSED[Đóng]
```

---

## 5. Trạng Thái Contact

```mermaid
stateDiagram-v2
    [*] --> new: Tổng đài tạo
    new --> picked: Sale pick (5p/lần)
    picked --> tiem_nang: Đang trao đổi
    tiem_nang --> chot: ✅ Chốt thành công
    tiem_nang --> fail: ❌ Thất bại
    fail --> caring_l1: CSKH Layer 1
    caring_l1 --> chot: Thành công
    caring_l1 --> caring_l2: Chuyển Layer 2
    caring_l2 --> chot: Thành công
    caring_l2 --> closed: Đóng
```

| Status | Mô tả | Color |
|--------|-------|-------|
| `new` | Mới tạo, chờ pick | 🔵 |
| `picked` | Đã nhận | 🟡 |
| `tiem_nang` | Đang trao đổi | 🟠 |
| `chot` | Chốt thành công | 🟢 |
| `fail` | Thất bại → CSKH | 🔴 |
| `caring_l1` | CSKH Layer 1 | 🟣 |
| `caring_l2` | CSKH Layer 2 | 🟣 |
| `closed` | Đóng | ⚫ |

---

## 6. Cơ Sở Dữ Liệu (ERD)

```mermaid
erDiagram
    teams ||--o{ users : has
    teams ||--o{ contacts : assigned
    
    users ||--o{ contacts : creates
    users ||--o{ contacts : picks
    users ||--o{ deals : closes
    users ||--o{ interactions : creates
    
    contacts ||--o{ interactions : has
    contacts ||--o{ status_history : has
    contacts ||--o{ deals : has
    
    deals ||--o{ deal_products : has
    deals ||--o{ payment_history : has
    products ||--o{ deal_products : included
    
    roles ||--o{ user_roles : has
    users ||--o{ user_roles : has

    teams {
        int id PK
        string name
        int manager_id FK
        string region
    }
    
    users {
        int id PK
        string username
        string email
        int team_id FK
        boolean active
    }
    
    contacts {
        int id PK
        string code
        string customer_name
        string phone
        enum need_type
        enum source
        enum status
        int team_id FK
        int assigned_to FK
        int created_by FK
    }
    
    deals {
        int id PK
        int contact_id FK
        decimal total_amount
        enum payment_status
        int closed_by FK
    }
    
    products {
        int id PK
        string code
        string name
        decimal base_price
    }
```

### Danh Sách Tables

| # | Table | Mô tả |
|---|-------|-------|
| 1 | teams | Quản lý teams (HN, HCM, Thực tập) |
| 2 | users | Nhân viên |
| 3 | roles | Vai trò |
| 4 | permissions | Quyền |
| 5 | contacts | Leads/Contacts |
| 6 | interactions | Lịch sử trao đổi |
| 7 | status_history | Lịch sử chuyển status |
| 8 | products | Sản phẩm/Dịch vụ |
| 9 | coupons | Mã giảm giá |
| 10 | deals | Deals khi chốt |
| 11 | deal_products | SP trong deal |
| 12 | payment_history | Lịch sử thanh toán |
| 13 | activity_logs | Audit logs |
| 14 | notification_rules | Rules thông báo |

---

## 7. Modules Overview

| # | Module | Mô tả | Priority |
|---|--------|-------|----------|
| 01 | [Authentication](./01-authentication/) | Login, logout, forgot password | Cao |
| 02 | [Permissions](./02-permissions/) | Dynamic roles & permissions | Cao ⭐ |
| 03 | [Contacts](./03-contacts/) | Quản lý contacts, pick mechanism | Cao ⭐ |
| 04 | [Employees](./04-employees/) | Quản lý nhân viên | Cao |
| 05 | [Notifications](./05-notifications/) | Web Push, Email, Zalo | Cao ⭐ |
| 06 | [Logs](./06-logs/) | Audit trail | Cao |
| 07 | [Reports](./07-reports/) | Dashboard & báo cáo | Trung |
| 10 | [Products](./10-products/) | Sản phẩm, Coupons | Cao |
| 11 | [Teams](./11-teams/) | Quản lý teams | Cao |
| 12 | [Deals](./12-deals/) | Quản lý deals | Cao |

---

## 8. Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Ruby on Rails 7+ |
| **Frontend** | HTML, CSS, JS, Hotwire |
| **Database** | MySQL 8+ |
| **Cache/Queue** | Redis |
| **Background Jobs** | Sidekiq |
| **Notifications** | Web Push, Email, Zalo OA |
| **AI** | Sentiment Analysis API |

---

## 9. Thông Tin Contact

| Field | Mô tả |
|-------|-------|
| code | Mã liên hệ (tự sinh) |
| customer_name | Tên khách (Zalo) |
| phone | Số điện thoại |
| need_type | TLDN, Thay đổi TT, Giấy phép con, Kế toán, FDI, SHTT, Khác |
| source | Ladi Zalo, Ladi Hotline, FB Mess, FB Hotline, Google, Giới thiệu, Khác |
| team_id | Team tư vấn |
| assigned_to | Sale đã pick |
| status | new → picked → tiem_nang → chot/fail |

---

## 10. Thông Tin Deal

| Field | Mô tả |
|-------|-------|
| contact_id | Liên kết Contact |
| total_amount | Tổng giá trị |
| payment_status | pending, partial, paid, refunded |
| deal_products | Nhiều SP, mỗi SP có: quantity, unit_price, closed_at |

---

## 11. Timeline (Phase 1)

```mermaid
gantt
    title LawCRM Phase 1
    dateFormat  YYYY-MM-DD
    
    section Core
    Authentication      :done, auth, 2026-01-20, 3d
    Permissions         :done, perm, after auth, 5d
    Teams               :done, team, after perm, 2d
    
    section Business
    Contacts            :active, cont, after team, 7d
    Deals               :deal, after cont, 5d
    Products            :prod, after deal, 3d
    
    section Features
    Notifications       :noti, after cont, 5d
    Logs                :logs, after noti, 3d
    Reports             :rpt, after logs, 3d
```

---

## 12. Tài Liệu Tham Khảo

| File | Nội dung |
|------|----------|
| [00-overview](./00-overview/) | Tổng quan dự án |
| [08-database](./08-database/) | Database schema chi tiết |
| [09-phases](./09-phases/) | Timeline & milestones |

---

> **Ghi chú**: Tài liệu này là bản tổng hợp. Chi tiết từng module xem trong folder tương ứng.
