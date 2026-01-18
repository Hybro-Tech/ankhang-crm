# 🏛️ AnKhangCRM

> **Hệ thống quản lý khách hàng cho doanh nghiệp**  
> Phiên bản 1.0 - Đang trong giai đoạn phân tích & thiết kế

![Status](https://img.shields.io/badge/status-SRS%20Complete-green)
![Version](https://img.shields.io/badge/version-1.0-blue)
![Standard](https://img.shields.io/badge/standard-IEEE%20830%20%7C%20ISO%2029148-purple)

---

## 🎯 Mục Tiêu

- **CRM chuyên nghiệp** - Quản lý Khách hàng, Cơ hội, Đơn hàng
- **Cơ chế Pick Contact** - Phân bổ Lead công bằng cho Sales Team
- **Thông báo đa kênh** - Email, Zalo OA (ZNS), Web Push
- **Phân quyền động** - Admin tự tạo roles & permissions
- **Audit Trail** - Ghi log toàn bộ hoạt động hệ thống

---

## 📋 Tài Liệu Dự Án

### Tài liệu chính
| Tài liệu | Mô tả | Trạng thái |
|----------|-------|------------|
| [📄 SRS v1.0](./docs/AnKhangCRM_SRS_v1.0.md) | Đặc tả yêu cầu phần mềm (IEEE 830) | ✅ Hoàn thành |
| [🎨 Wireframes](./docs/ui-design/wireframes/) | 24 màn hình HTML mockups | ✅ Hoàn thành |

### Modules chính (theo SRS)
| Module | Chức năng |
|--------|-----------|
| Authentication | Đăng nhập, Quên mật khẩu, Session Management |
| Permissions | RBAC động với Ma trận quyền |
| Contacts | Quản lý KH + cơ chế **Pick** |
| Deals | Pipeline, Trạng thái thanh toán |
| Products & Coupons | Sản phẩm, Khuyến mãi |
| Teams & Employees | Quản lý đội nhóm, nhân viên |
| Reports & Dashboard | KPIs, Biểu đồ, Top Performers |
| Audit Logs | Nhật ký hoạt động đầy đủ |

---

## 📁 Cấu Trúc Thư Mục

```
crm-docs/
├── README.md
├── docs/
│   ├── AnKhangCRM_SRS_v1.0.md     ← Tài liệu SRS chính
│   ├── diagrams/                   ← Sơ đồ nghiệp vụ (PNG)
│   └── ui-design/
│       └── wireframes/             ← 24 màn hình HTML
│           ├── dashboard.html
│           ├── contacts_list.html
│           ├── deals_form.html
│           ├── roles.html
│           └── ...
└── .agent/                         ← AI Agent configs
```

---

## 🛠️ Tech Stack (Dự kiến)

| Layer | Technology |
|-------|------------|
| **Backend** | Ruby on Rails 7+ |
| **Frontend** | HTML, CSS, JS + Hotwire |
| **Database** | MySQL 8+ |
| **Cache/Queue** | Redis + Sidekiq |
| **External APIs** | Zalo OA API, Email Service |
| **Hosting** | AWS / VPS |

---

## 🔒 Tiêu chuẩn tuân thủ

| Tiêu chuẩn | Mô tả |
|------------|-------|
| **IEEE 830** | Cấu trúc SRS chuẩn |
| **ISO/IEC/IEEE 29148** | Yêu cầu phi chức năng mở rộng |
| **GDPR** | Right to be Forgotten |
| **Security** | AES-256, TLS 1.3, Row-level Security |
| **Reliability** | RPO < 15 phút, RTO < 4 giờ, Uptime 99.9% |

---

## 📅 Trạng Thái Dự Án

| Giai đoạn | Trạng thái |
|-----------|------------|
| Requirements (SRS) | ✅ Hoàn thành |
| UI/UX Wireframes | ✅ Hoàn thành |
| Database Design | ⏳ Đang chờ |
| Backend Development | ⏳ Đang chờ |
| Frontend Development | ⏳ Đang chờ |
| Testing & QA | ⏳ Đang chờ |

---

## 👥 Đội Ngũ

- **Product Owner**: [Tên]
- **Developer**: David
- **AI Assistant**: Antigravity

---

> 📌 **Quy trình**: SRS → Wireframes → Database Design → Development → Testing
