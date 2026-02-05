# Quy Trình Phân Phối Khách Hàng 3 Lớp

> **Phiên bản:** 1.0  
> **Cập nhật:** 05/02/2026

---

## Tổng Quan

Khi Tổng Đài nhập khách hàng mới vào hệ thống, hệ thống sẽ tự động phân phối đến nhân viên Sale theo quy trình 3 lớp:

```
Khách hàng mới → Lớp 1 (1 Sale) → Lớp 2 (Vùng miền) → Lớp 3 (Toàn quốc)
```

---

## Chi Tiết 3 Lớp

### 🔵 Lớp 1: Phân Phối Ngẫu Nhiên (T+0)

**Thời điểm:** Ngay khi khách hàng được tạo

**Logic:**
- Hệ thống chọn **1 Sale ngẫu nhiên** từ danh sách Sale được cấu hình cho **Loại Dịch Vụ** của khách hàng
- **Luân phiên công bằng**: Mỗi Sale được chọn 1 lần, khi tất cả đã được chọn thì bắt đầu vòng mới
- Danh sách luân phiên reset vào đầu mỗi ngày

**Kết quả:** 
- Sale được chọn nhận thông báo
- Khách hàng chỉ hiển thị cho Sale này trong 2 phút

**Điều kiện bỏ qua:**
- Ngoài giờ làm việc → Nhảy thẳng Lớp 3
- Không có Sale nào cấu hình cho loại dịch vụ → Nhảy Lớp 2

---

### 🟡 Lớp 2: Mở Rộng Vùng Miền (T+2 phút)

**Thời điểm:** 2 phút sau khi tạo khách hàng (nếu chưa ai nhận)

**Logic:**
- Từ **Tỉnh/Thành** của khách hàng → Xác định **Vùng/Miền**
- Gửi thông báo cho **tất cả Sale** thuộc Vùng/Miền đó

**Kết quả:**
- Tất cả Sale trong vùng nhận thông báo
- Khách hàng hiển thị cho tất cả Sale trong vùng

**Điều kiện bỏ qua:**
- Không có Sale nào trong vùng → Nhảy Lớp 3

---

### 🔴 Lớp 3: Mở Rộng Toàn Quốc (T+4 phút)

**Thời điểm:** 4 phút sau khi tạo khách hàng (nếu vẫn chưa ai nhận)

**Logic:**
- Gửi thông báo cho **tất cả Sale** trong hệ thống

**Kết quả:**
- Khách hàng hiển thị và có thể nhận bởi bất kỳ Sale nào

---

## Sơ Đồ Quy Trình

```
┌─────────────────────────────────────────────────────────────┐
│                 KHÁCH HÀNG MỚI ĐƯỢC TẠO                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
           ┌──────── Trong giờ làm việc? ────────┐
           │                                      │
          Có                                    Không
           │                                      │
           ▼                                      │
┌─────────────────────┐                           │
│      LỚP 1          │                           │
│  Chọn 1 Sale        │                           │
│  (luân phiên)       │                           │
│  Chờ 2 phút         │                           │
└─────────────────────┘                           │
           │                                      │
           ▼                                      │
      Đã có người nhận? ──── Có ──────────────────┼──── ✅ HOÀN TẤT
           │                                      │
         Không                                    │
           │                                      │
           ▼                                      │
┌─────────────────────┐                           │
│      LỚP 2          │                           │
│  Thông báo toàn bộ  │                           │
│  Sale trong Vùng    │                           │
│  Chờ 2 phút         │                           │
└─────────────────────┘                           │
           │                                      │
           ▼                                      │
      Đã có người nhận? ──── Có ──────────────────┼──── ✅ HOÀN TẤT
           │                                      │
         Không                                    │
           │                                      │
           ▼                                      ▼
┌─────────────────────────────────────────────────────────────┐
│                         LỚP 3                               │
│              Thông báo TOÀN BỘ Sale toàn quốc               │
└─────────────────────────────────────────────────────────────┘
```

---

## Cấu Hình Cần Thiết

| Cấu hình                       | Mục đích                                           |
| ------------------------------ | -------------------------------------------------- |
| **Giờ làm việc**               | Quyết định có áp dụng Lớp 1,2 hay nhảy thẳng Lớp 3 |
| **Thời gian chờ giữa các lớp** | Mặc định 2 phút, có thể thay đổi                   |
| **Sale ↔ Loại Dịch Vụ**        | Xác định Sale nào nhận khách hàng loại nào (Lớp 1) |
| **Sale ↔ Vùng/Miền**           | Xác định Sale nào thuộc vùng nào (Lớp 2)           |
| **Tỉnh/Thành ↔ Vùng/Miền**     | Mapping địa lý để xác định Lớp 2                   |

---

## Ví Dụ Thực Tế

**Tình huống:** Khách hàng mới từ Hà Nội, dịch vụ "Thành lập công ty"

| Thời gian | Lớp | Hành động                                                      |
| --------- | --- | -------------------------------------------------------------- |
| T+0       | 1   | Sale A (được cấu hình cho "Thành lập công ty") nhận thông báo  |
| T+2 phút  | 2   | Sale A không nhận → Tất cả Sale vùng "Miền Bắc" nhận thông báo |
| T+4 phút  | 3   | Vẫn không ai nhận → Tất cả Sale toàn quốc nhận thông báo       |

---

## Lưu Ý

1. **Luân phiên công bằng**: Mỗi Sale được chọn 1 lần, reset mỗi ngày
2. **Khi Sale nhận khách hàng**: Quy trình dừng, khách hàng được gán cho Sale đó
3. **Chỉ áp dụng cho Role Sale**: User có role Sale mới tham gia quy trình này
