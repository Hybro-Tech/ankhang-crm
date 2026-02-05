# Đề Xuất Cải Tiến AnKhangCRM - Phase 2+

> **Ngày tạo:** 05/02/2026  
> **Nguồn tham khảo:** Salesforce, HubSpot, Zoho CRM  
> **Trạng thái:** Đang xem xét

---

## 📊 Tình Trạng Hiện Tại

AnKhangCRM đã đạt **~80% tính năng** so với các CRM lớn cho luồng Tổng đài → Sale:
- ✅ Round-robin distribution
- ✅ Territory/Region routing (3 layers)
- ✅ Service Type routing (UserServiceTypeLimit)
- ✅ Daily pick limits
- ✅ Real-time notifications (Turbo, WebPush, Email)
- ✅ Working hours awareness
- ✅ Cooldown between picks

---

## 🔴 HIGH PRIORITY

### 1. Lead Scoring (Điểm Lead)

**Mô tả**: Tự động chấm điểm lead dựa trên các tín hiệu để ưu tiên lead chất lượng cao.

| Signal                     | Points | Lý do                           |
| -------------------------- | ------ | ------------------------------- |
| Nguồn: Hotline             | +20    | Khách chủ động gọi = intent cao |
| Nguồn: Facebook Ads        | +10    | Trả phí quảng cáo               |
| Province: Hà Nội/HCM       | +15    | Thị trường lớn                  |
| Service Type: Thành lập DN | +25    | Dịch vụ chính                   |
| Có email                   | +5     | Dễ follow-up                    |
| Có Zalo                    | +10    | Kênh liên lạc nhanh             |

**Lợi ích**:
- Sale nhận lead điểm cao trước → faster response
- Tối ưu conversion rate
- Dữ liệu cho báo cáo chất lượng nguồn

**Effort**: 3-5 ngày

---

### 2. Weighted Distribution (Phân bổ có trọng số)

**Mô tả**: Thay vì round-robin đều, phân bổ lead theo performance của Sale.

**Ví dụ**:
```
Sale A: 40% leads (conversion 30%, có experience)
Sale B: 35% leads (conversion 25%)
Sale C: 25% leads (conversion 15%, mới vào)
```

**Lợi ích**:
- Sale giỏi nhận nhiều lead hơn → tối ưu revenue
- Có thể điều chỉnh theo capacity thực tế
- Training progression cho Sale mới

**Effort**: 3-5 ngày

---

## 🟡 MEDIUM PRIORITY

### 3. Rep Online Status

**Mô tả**: Chỉ route lead cho Sale đang online/trong shift.

**Implementation**:
```ruby
# User model additions
online_at: datetime      # Updated via Turbo ping mỗi 30s
shift_start: time        # Ca làm việc bắt đầu
shift_end: time          # Ca làm việc kết thúc
status: enum             # online, away, offline, on_break
```

**Lợi ích**:
- Không gán lead cho Sale đang offline
- Tránh lead bị delay response
- Hỗ trợ working shift khác nhau

**Effort**: 3-4 ngày

---

### 4. SLA Response Time Tracking

**Mô tả**: Đo lường và alert thời gian phản hồi.

| Metric                 | Target          | Alert Condition               |
| ---------------------- | --------------- | ----------------------------- |
| Time to First Response | < 5 phút        | Notify Team Lead nếu > 3 phút |
| Time to Pick           | < 2 phút/layer  | Auto-escalate nếu miss        |
| Follow-up Rate         | > 80% trong 24h | Đưa vào Blacklist nếu miss    |

**Lợi ích**:
- Báo cáo performance rõ ràng
- QA/CSKH có data để review
- Improve response culture

**Effort**: 5-7 ngày

---

## 🟢 LOW PRIORITY

### 5. Capacity Capping

**Mô tả**: Giới hạn workload tổng (không chỉ daily pick).

**Ví dụ**:
- Sale tối đa 50 contacts đang xử lý (status = potential)
- Khi đạt giới hạn → Không nhận lead mới cho đến khi close/fail

---

### 6. Lead Source Priority

**Mô tả**: Route lead từ nguồn premium nhanh hơn.

**Ví dụ**:
- Hotline → Layer 1 timeout: 1 phút (thay vì 2)
- Facebook → Layer 1 timeout: 3 phút
- Organic → Standard 2 phút

---

## 📅 Recommended Roadmap

| Sprint     | Feature               | Effort   | Dependencies      |
| ---------- | --------------------- | -------- | ----------------- |
| Sprint 8   | Lead Scoring (basic)  | 3-5 days | None              |
| Sprint 9   | Weighted Distribution | 3-5 days | Lead Scoring data |
| Sprint 10  | Online Status + SLA   | 5-7 days | None              |
| Sprint 11+ | Capacity Capping      | 2-3 days | None              |

---

## 📝 Notes

1. **Lead Scoring** nên làm trước vì data từ scoring sẽ feed vào Weighted Distribution
2. **Online Status** có thể làm độc lập, không phụ thuộc các feature khác
3. Tất cả features đều backward-compatible, không break flow hiện tại

---

## 🔗 References

- Salesforce Lead Assignment Rules: leandata.com
- HubSpot Workflow Automation: hubspot.com/workflows
- Zoho Territory Management: zoho.com/crm/territory-management
