# TODO - Role-Based Dashboard System

> **Cập nhật lần cuối:** 2026-01-28

---

## ✅ Đã Hoàn Thành

### Sprint Current
- [x] Permission-Based Sidebar
  - [x] `sidebar_section` helper for dynamic visibility
  - [x] 18 new permissions (dashboards, saturday_schedules, reports, logs)
  - [x] Role-permission assignments updated
  
- [x] Admin Dashboard
  - [x] KPI Cards (Tổng KH, NV, Đơn chốt, Tỷ lệ chốt)
  - [x] Trend chart (7 ngày)
  - [x] Team comparison chart
  - [x] Sales comparison chart
  - [x] Top performers table
  - [x] Activity log

---

## 🔲 Cần Làm - Phase 1

### Tổng Đài Updates
- [x] Add time filter (today/week/month) to contact list
- [x] Create statistics page with:
  - [x] KPI cards (today/week/month counts)
  - [x] Line chart: trend nhập liệu
  - [x] Progress bar: target hàng ngày
  - [x] Table: contacts chưa assign

### Sale Kanban
- [x] Create `_sale_kanban.html.erb` partial (Used standalone view instead)
- [x] Columns: Tiềm năng → Đàm phán → Chốt → Thất bại
- [x] Implement drag-drop with Stimulus
- [x] Update contact status via Turbo Stream
- [x] Add Kanban link to Sales workspace

### CSKH Dashboard
- [x] Create `_cskh_dashboard.html.erb`
- [x] Queue list: all customers needing care (Recovery & After-Sales)
- [x] KPI cards: cases today, pending, avg response time
- [x] Quick actions panel (placeholder)
- [x] Create CSKH statistics page (Integrated into Dashboard)

### ZNS Placeholder
- [x] Create `app/views/zns/` directory (Integrated in CSKH Dashboard)
- [x] Compose message UI (placeholder in dashboard)
- [x] Template management UI (placeholder in dashboard)
- [x] Rules configuration UI (placeholder only)

---

## 📋 TODO - Sprint 3-4 (Export Features)

### Tổng Đài Export
- [ ] Add Export Excel button for created contacts
- [ ] Export danh sách contacts đã tạo theo time filter

### Admin Export Report
- [ ] Create `ReportsController#export`
- [ ] Support Excel (.xlsx) format
- [ ] Support PDF format (optional)
- [ ] Add export button to Admin dashboard

---

## 📋 TODO - Phase 2 (Future)

### Admin Enhancements
- [ ] Switch view: xem dashboard của role khác
- [ ] KPI target settings: cài đặt target cho team/NV
- [ ] Dashboard customization: drag/drop widgets

### CSKH Enhancements
- [ ] Priority scoring: VIP, thời gian chờ
- [ ] Customer satisfaction survey
- [ ] ZNS Rules Engine: gửi tự động theo rules

### All Roles
- [ ] Real-time notifications (ActionCable)
- [ ] Mobile responsive optimization
- [ ] Dark mode support

---

## 📝 Notes

### Sidebar Permission Decision
> Sử dụng **CanCanCan abilities hiện có** thay vì thêm field `visible_menus` cho Role.  
> Lý do: Hệ thống RBAC đã hoàn chỉnh, `can_access?` helper hoạt động tốt.

### Revenue Calculation
> Hiện tại dùng placeholder `0` cho revenue vì chưa có Deal model.  
> TODO: Khi implement Deal feature, cập nhật `build_admin_kpi` trong `DashboardController`.

### Files Created
```
app/views/dashboard/_admin_dashboard.html.erb
app/controllers/concerns/admin_dashboard_concern.rb (prepared, not used yet)
db/seeds.rb (updated with new permissions)
app/views/shared/_sidebar.html.erb (updated)
app/helpers/application_helper.rb (added sidebar_section)
```

---

## Estimated Effort

| Component | Effort | Priority |
|-----------|--------|----------|
| Tổng Đài Updates | 1 sprint | High |
| Sale Kanban | 1 sprint | Medium |
| CSKH Dashboard | 1-2 sprints | Medium |
| Export Report | 0.5 sprint | Medium |
| **Total** | **3.5-4.5 sprints** | - |
