# 💼 Meeting Prep: Kickoff & Sign-off

> **Date**: 22/01/2026  
> **Goal**: Chốt Spec, Design, Timeline để Start dự án vào ngày 19/01 (đã start)

---

## 1. 🕒 Review Timeline & Plan

**Điểm nhấn quan trọng cần nói với khách:**
- [ ] **Ngày Start**: Confirm là **19/01/2026**.
- [ ] **Nghỉ Tết**: Nhấn mạnh project có **2 tuần "Pause"** (10/02 - 23/02). Plan đã tính toán việc này, deadline 31/03 vẫn khả thi.
- [ ] **Sprint 1 (19-23/01) & Sprint 2 (26/01-09/02)**: Trước Tết phải xong **Login + Phân quyền + Database + Teams**. Đây là "xương sống", làm kỹ thì ra Tết chạy tính năng mới nhanh.
- [ ] **Sprint 3 (24/02 - 09/03)**: Core Features (Contacts, Pick, Deals).
- [ ] **Sprint 4 (10/03 - 23/03)**: Finish All Features (Noti, Dashboard, Reports).
- [ ] **Sprint 5 (24/03 - 31/03)**: Verification, Tuning & Handover (Tuần đệm quan trọng).
- [ ] **Deadline**: **31/03/2026** (Full feature + Deploy).

---

## 2. 📝 Review Requirements (SRS)

Tôi đã rà soát lại SRS, đa số đã rất chi tiết. Tuy nhiên, hãy confirm nhanh các điểm "xám" này để tránh cãi nhau sau này:

### A. Cơ chế Pick Contact (Quan trọng nhất)
- [ ] **Logic**: Cooldown 5 phút/lần pick.
- [ ] **Q**: Có cần giới hạn số lượng contact *đang xử lý* (ví dụ: ko được giữ quá 50 khách cùng lúc) không? -> *SRS hiện tại: Không giới hạn.*
- [ ] **Q**: Nếu Sale pick xong "ngâm" đó không gọi thì sao? Có cần cơ chế **Auto-release** (nhả khách) sau 24h không?

### B. Zalo OA Integration
- [ ] **Cost**: Ai trả tiền phí gửi tin ZNS? (Thường là Khách hàng nạp tiền vào Zalo OA). Cần làm rõ ngay để họ không shock chi phí.
- [ ] **Template**: Nội dung tin nhắn phải đăng ký với Zalo trước. Cần khách cung cấp nội dung mẫu ngay tuần đầu tiên.

### C. Import Data
- [ ] **Scope**: Import Excel/CSV hiện đang ở **Sprint 3 hoặc 4**. Khách có cần *ngay* khi launch không? Nếu có -> Timeline có thể bị ảnh hưởng.

---

## 3. 🛡️ Audit: Design & Setup Review (Quan trọng)

Tôi đã rà soát toàn bộ mockup và thấy thiếu một số màn hình quan trọng cần confirm với khách:

### A. Design Gaps (Đã bổ sung ✅)
| Màn hình | Mức độ | Trạng thái |
|----------|--------|------------|
| **Trang cá nhân (Profile)** | 🟡 Medium | ✅ Đã tạo `profile.html` |
| **Quản lý mẫu Zalo (ZNS)** | 🔴 Critical | ✅ Đã tạo `zalo_templates.html` |
| **Reset Password** | 🟢 Low | ✅ Đã tạo `reset_password.html` |

### B. Logic Questions (Cần làm rõ)
1.  **Thanh toán một phần (Partial Payment)**:
    *   SRS hiện tại chỉ có trạng thái `Partial`.
    *   **Q**: Khách có cần ghi nhận cụ thể *số tiền đã trả* (Ví dụ: Tổng 10tr, đã cọc 3tr, còn thiếu 7tr) hay chỉ cần gắn nhãn là xong?
    *   *Lời khuyên*: Nếu cần quản lý công nợ chính xác -> Cần thêm bảng `PaymentHistory`.

2.  **Pick Contact**:
    *   **Q**: Nếu Sale A pick khách, nhưng bận nghỉ phép. Admin có quyền **"Cướp"** khách đó gán cho Sale B không? (Cần nút "Re-assign" cho Admin).

---

## 4. 🎨 Review Design / Mockup

- [ ] **Mobile Responsiveness**: Sale có hay dùng điện thoại để pick khách/update trạng thái không?
    - *Team sẽ làm Responsive Web*, nhưng nếu họ cần trải nghiệm như Native App thì cần làm rõ kỳ vọng.
- [ ] **Màu sắc/Logo**: Đã chốt theo brand identity chưa?

---

## 4. 🛠 Technical & Deployment

Những câu hỏi "phụ" nhưng quan trọng để setup server:
- [ ] **Domain**: Họ đã có domain chưa (ví dụ: `crm.ankhang.vn`)?
- [ ] **Hạ tầng**: Deploy lên server của họ hay mình tự mua VPS? (Khuyên dùng VPS riêng như DigitalOcean/AWS, cost ~10-20$/tháng).
- [ ] **Backup**: Dữ liệu có cần backup ra server vật lý khác không (off-site)?

---

## 5. ✅ Checklist mang đi họp

1. [ ] Mở file `docs/IMPLEMENTATION_PLAN.md` (đã update timeline Tết).
2. [ ] Mở file `docs/AnKhangCRM_SRS_v1.0.md` (nếu cần tra cứu chi tiết).
3. [ ] Mở bộ Mockup HTML (trên trình duyệt) để demo flow.
4. [ ] In/Gửi file `MEETING_PREP.md` này làm sườn trao đổi.
