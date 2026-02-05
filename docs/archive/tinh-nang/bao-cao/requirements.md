# 📊 Module: Reports & Dashboard

> **Module ID**: RPT  
> **Priority**: Trung  
> **Phase**: 1

---

## 1. Tổng Quan

Module cung cấp dashboard tổng quan và báo cáo để managers theo dõi hiệu suất kinh doanh.

---

## 2. Yêu Cầu Chức Năng

| ID | Yêu cầu | Ưu tiên | Phase |
|----|---------|---------|-------|
| RPT-001 | Dashboard tổng quan | Cao | 1 |
| RPT-002 | Stats cards (KPIs) | Cao | 1 |
| RPT-003 | Biểu đồ contacts theo trạng thái | Cao | 1 |
| RPT-004 | Trend chart (theo thời gian) | Trung | 1 |
| RPT-005 | Top performers table | Trung | 1 |
| RPT-006 | Thống kê theo team | Trung | 1 |
| RPT-007 | Date range filter | Trung | 1 |
| RPT-008 | Export reports to PDF/Excel | Thấp | 2 |
| RPT-009 | Scheduled reports (email) | Thấp | 2 |

---

## 3. Dashboard Widgets

### 3.1 KPI Cards

| Card | Metric | Calculation |
|------|--------|-------------|
| 📊 Tổng Contacts | Total contacts | COUNT(contacts) |
| ➕ Contacts Mới (Tuần) | New this week | COUNT WHERE created_at > 7 days ago |
| 🟢 Chốt Thành Công | Deals closed | COUNT WHERE status = 'chot' |
| 📈 Tỷ Lệ Chốt | Conversion rate | chot / total * 100% |
| 💰 Doanh Thu | Revenue | SUM(deals.total_amount) |

### 3.2 Charts

| Chart | Type | Data |
|-------|------|------|
| Phân Bổ Trạng Thái | Pie/Donut | Contacts by status |
| Trend Contacts Mới | Line | New contacts by day/week/month |
| So Sánh Sales | Bar | Contacts picked by Sales |
| Doanh Thu theo Team | Bar | Revenue by team |

### 3.3 Tables

| Table | Columns | Purpose |
|-------|---------|---------|
| Top Performers | Name, Contacts Picked, Deals Chốt, Revenue | Hiệu suất Sales |
| Recent Activities | Time, User, Action | Feed hoạt động gần đây |
| Contacts Fail | Contact, Assigned CSKH, Days | CSKH đang chăm sóc |

---

## 4. User Stories

| ID | Vai trò | Mong muốn | Để | Priority |
|----|---------|-----------|-----|----------|
| US-060 | Manager | Xem dashboard khi login | Nắm tổng quan ngay | Cao |
| US-061 | Manager | Xem pie chart KH theo status | Biết phân bổ | Cao |
| US-062 | Manager | Xem trend theo tuần/tháng | Biết xu hướng | Trung |
| US-063 | Manager | Xem ai tạo nhiều KH nhất | Đánh giá NV | Trung |
| US-064 | Manager | Filter by date range | Xem period cụ thể | Trung |
| US-065 | Admin | Xem system health metrics | Monitor | Thấp |

---

## 5. UI/UX Notes

### 5.1 Dashboard Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 📊 Dashboard                              Period: [This Month ▼] [Refresh]  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐    │
│ │ 📊 Tổng KH    │ │ ➕ KH Mới     │ │ 🟢 Hoàn Thành │ │ 📈 Conversion  │    │
│ │               │ │               │ │               │ │               │    │
│ │     156       │ │      23       │ │      89       │ │    57.1%      │    │
│ │  ▲ 12% vs LM  │ │  ▼ 5% vs LM   │ │  ▲ 8% vs LM   │ │  ▲ 3% vs LM   │    │
│ └───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘    │
│                                                                             │
│ ┌─────────────────────────────────────┐ ┌─────────────────────────────────┐ │
│ │ 📈 Trend Khách Hàng Mới             │ │ 🥧 Phân Bổ Theo Trạng Thái      │ │
│ │ ┌───────────────────────────────┐   │ │                                 │ │
│ │ │      ╱\                       │   │ │      ┌────────────────────┐    │ │
│ │ │     ╱  \    ╱\                │   │ │      │   🟢 Hoàn thành    │    │ │
│ │ │    ╱    \  ╱  \    ╱\         │   │ │      │       57%          │    │ │
│ │ │   ╱      \/    \  ╱  \        │   │ │      ├────────────────────┤    │ │
│ │ │  ╱              \/    \       │   │ │      │ 🟠 Đang xử lý 20%  │    │ │
│ │ │ T2   T3   T4   T5   T6   T7   │   │ │      │ 🔵 Tiềm năng 15%   │    │ │
│ │ └───────────────────────────────┘   │ │      │ 🔴 Từ chối 8%      │    │ │
│ └─────────────────────────────────────┘ └─────────────────────────────────┘ │
│                                                                             │
│ ┌─────────────────────────────────────┐ ┌─────────────────────────────────┐ │
│ │ 🏆 Top Performers                   │ │ 🔔 Recent Activities            │ │
│ │                                     │ │                                 │ │
│ │  #  Name          KH Mới  Completed │ │  • 10m ago - nguyen.a created   │ │
│ │  1  Nguyễn A        15       12     │ │    customer "Trần B"            │ │
│ │  2  Trần B          12        9     │ │  • 25m ago - tran.b updated     │ │
│ │  3  Lê C             8        7     │ │    customer #123                │ │
│ │  4  Phạm D           5        4     │ │  • 1h ago - admin created       │ │
│ │                                     │ │    employee "Le C"              │ │
│ └─────────────────────────────────────┘ └─────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. API Endpoints

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|------------|
| GET | `/api/v1/dashboard/stats` | KPI cards data | `reports.view` |
| GET | `/api/v1/dashboard/charts/status` | Status distribution | `reports.view` |
| GET | `/api/v1/dashboard/charts/trend` | Trend data | `reports.view` |
| GET | `/api/v1/dashboard/top-performers` | Top employees | `reports.view` |
| GET | `/api/v1/dashboard/activities` | Recent activities | `reports.view` |

### Query Parameters

| Param | Type | Description |
|-------|------|-------------|
| `period` | string | `today`, `week`, `month`, `quarter`, `year` |
| `from` | date | Custom start date |
| `to` | date | Custom end date |

### Response Example (Stats)

```json
{
  "data": {
    "total_customers": 156,
    "new_customers": 23,
    "completed_customers": 89,
    "conversion_rate": 57.1,
    "comparisons": {
      "total_customers": { "value": 12, "type": "increase" },
      "new_customers": { "value": -5, "type": "decrease" },
      "completed_customers": { "value": 8, "type": "increase" },
      "conversion_rate": { "value": 3, "type": "increase" }
    }
  },
  "period": {
    "from": "2026-01-01",
    "to": "2026-01-18",
    "compare_from": "2025-12-01",
    "compare_to": "2025-12-18"
  }
}
```

---

## 7. Chart Libraries

| Option | Pros | Cons |
|--------|------|------|
| **Chart.js** | Simple, lightweight | Less features |
| **ApexCharts** | Beautiful, many types | Larger bundle |
| **ECharts** | Powerful, interactive | Complex API |

**Recommendation**: ApexCharts for beautiful default styling

---

## 8. Performance Considerations

### 8.1 Caching Strategy

| Data | Cache TTL | Invalidation |
|------|-----------|--------------|
| Today stats | 5 minutes | On customer change |
| Weekly/Monthly | 1 hour | Scheduled |
| Trend charts | 1 hour | Scheduled |

### 8.2 Pre-computed Aggregates

```sql
-- Daily aggregates table
CREATE TABLE daily_stats (
  date DATE PRIMARY KEY,
  total_customers INT,
  new_customers INT,
  completed_customers INT,
  customers_by_status JSON,
  customers_by_user JSON,
  created_at DATETIME
);
```

---

## 9. Permissions

| Action | Permission |
|--------|------------|
| View dashboard | `reports.view` |
| View team stats only | `reports.view` + filter by team |
| Export reports | `reports.export` |

---

> **Related**: 
> - [03-customers.md](./03-customers.md) - Customer data source
> - [06-logs.md](./06-logs.md) - Activities data source
