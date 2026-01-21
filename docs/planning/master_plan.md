# AnKhangCRM - Implementation Plan

> **Version**: 1.1 (Final Proposal)  
> **Start Date**: 19/01/2026  
> **End Date**: 31/03/2026  
> **Total Duration**: ~10 weeks (bao gồm 2 tuần nghỉ Tết)

---

## 📅 Timeline Tổng Quan

```mermaid
gantt
    title AnKhangCRM - Implementation Timeline
    dateFormat  YYYY-MM-DD
    axisFormat  %d/%m
    excludes    weekend

    section Sprint 1
    Foundation (Setup, DB, Auth) :active, s1, 2026-01-19, 2026-01-23

    section Sprint 2
    Pre-Tet Core (RBAC, Teams)   :active, s2, 2026-01-26, 2026-02-09

    section OFF
    Nghỉ Tết                     :crit, off, 2026-02-10, 2026-02-23

    section Sprint 3
    Core Features (Contacts, Pick) :active, s3, 2026-02-24, 2026-03-09

    section Sprint 4
    Features Finish (Noti, Dashboard) :active, s4, 2026-03-10, 2026-03-23

    section Sprint 5
    Verify & Feedback Fixes      :active, s5, 2026-03-24, 2026-03-31
```

---

## 📝 Chi Tiết Các Sprint (Updated)

### Sprint 1: Foundation (Khởi động)
**Thời gian:** 19/01/2026 - 23/01/2026 (1 tuần)

Tuần đầu tiên tập trung setup hạ tầng để team có thể bắt đầu code ngay.
- **Hạ tầng:** Setup Rails, Docker, Database.
- **Database:** ERD, Core Tables.
- **Auth:** Login, Logout.
- **Output:** Môi trường Dev sẵn sàng, User đăng nhập được.

### Sprint 2: Pre-Tet Core
**Thời gian:** 26/01/2026 - 09/02/2026 (2 tuần)

Hoàn thiện các tính năng quản trị tổ chức để demo trước khi nghỉ Tết.
- **Authorization:** Phân quyền động (CanCanCan).
- **Organization:** Quản lý Teams, Employees.
- **Basic Contacts:** CRUD Khách hàng cơ bản (nếu kịp).
- **Output:** Hệ thống quản trị vận hành được (Admin/Manager/Sale).

### 🧧 Giai đoạn Nghỉ Tết (10/02 - 23/02)
- Server Development vẫn duy trì (demo mode).
- Team nghỉ ngơi.

### Sprint 3: Core Features
**Thời gian:** 24/02/2026 - 09/03/2026 (2 tuần)

Tập trung vào nghiệp vụ lõi Sales.
- **Contacts:** Quản lý khách hàng chuyên sâu.
- **Pick Mechanism:** Sales nhận khách (Critical).
- **Deals:** Quản lý cơ hội bán hàng.
- **Output:** Flow Guest → Lead → Deal hoàn thiện.

### Sprint 4: Feature Finish (Notifications & Dashboard)
**Thời gian:** 10/03/2026 - 23/03/2026 (2 tuần)

Hoàn tất toàn bộ tính năng trước khi bước vào tuần cuối.
- **Advanced Features:** Sản phẩm, Coupon, Zalo/Email Notifications.
- **Dashboard & Reports:** Biểu đồ KPI, Báo cáo doanh thu, Audit Logs.
- **Output:** **Hoàn thành 100% Feature Development.**

### Sprint 5: Verification & Handover
**Thời gian:** 24/03/2026 - 31/03/2026 (1 tuần)

Dành riêng cho việc kiểm thử, sửa lỗi theo feedback khách hàng và bàn giao.
- **Verify:** UAT (User Acceptance Testing) với khách hàng.
- **Fixes:** Sửa lỗi và tinh chỉnh UI/UX theo feedback.
- **Deployment:** Production Release.
- **Handover:** Bàn giao tài liệu và hướng dẫn sử dụng.

---

## ⚠️ Rủi ro & Giải pháp (Risk Management)

| Rủi ro | Mức độ | Giải pháp |
|--------|--------|-----------|
| **Nghỉ Tết làm gián đoạn mạch code** | Trung bình | Hoàn thành dứt điểm Phase 1 trước Tết. Viết document kỹ để bắt nhịp lại nhanh sau Tết. |
| **Zalo OA duyệt template lâu** | Cao | Đăng ký template ngay từ tuần đầu tiên của dự án. |
| **Phát sinh requirement mới** | Cao | Chốt cứng scope vào ngày 31/01. Mọi thay đổi sau đó sẽ đẩy sang Phase 2 (Maintenance). |

---

> **Cam kết:** Bàn giao hệ thống MVP (Minimum Viable Product) hoàn chỉnh vào ngày **31/03/2026**.
