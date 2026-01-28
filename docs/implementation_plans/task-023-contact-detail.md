# TASK-023: Chi tiết Contact & Lịch sử chăm sóc

> **Status**: ✅ Completed  
> **Started**: 2026-01-28
> **Completed**: 2026-01-28

## Goal

Xây dựng trang chi tiết Contact với Timeline tương tác (Interactions) theo wireframe `contact_detail.html`.

## Phân tích

### Đã có trước đó:
- `contacts#show` - Trang detail cơ bản
- Layout 3 cột (2+1)
- Thông tin contact, trạng thái, timeline đơn giản

### Đã thêm mới:
1. **Interaction model** - Lưu lịch sử tương tác
2. **Timeline view** - Hiển thị các interaction theo wireframe
3. **Form thêm interaction** - Textarea + buttons (call/email/calendar)
4. **Status progress** - Thanh tiến trình trạng thái

## Tasks

- [x] **Task 1**: Tạo model Interaction + migration
  - Fields: contact_id, user_id, content, interaction_method
  - Verify: `rails c` → `Interaction.create` thành công ✅

- [x] **Task 2**: Tạo controller `InteractionsController#create`
  - Nested under contacts: POST /contacts/:contact_id/interactions
  - Turbo Stream response để append vào timeline ✅

- [x] **Task 3**: Cập nhật `contacts#show` - Load interactions
  - Include interactions trong controller ✅

- [x] **Task 4**: Tạo partial `_form.html.erb`
  - Textarea với placeholder
  - Buttons: Call, Zalo, Email, Meeting, Note icons
  - Submit button "Lưu Hoạt động" ✅

- [x] **Task 5**: Tạo partial `_interaction.html.erb` + `_timeline.html.erb`
  - Loop qua interactions
  - Icon theo method (phone=blue, email=gray, meeting=green, note=yellow)
  - Content + relative time ✅

- [x] **Task 6**: Tạo partial `_status_progress.html.erb`
  - Progress bar: Mới → Tiềm năng → Đang tư vấn → Chốt
  - Highlight current status
  - Special handling for Failed, CSKH ✅

- [x] **Task 7**: Update show.html.erb layout theo wireframe
  - Status Progress ở header
  - Customer info card bên trái (avatar, phone, email, service type, etc.)
  - Tabs (Tương tác | Deals | Tài liệu) bên phải
  - Form + Timeline trong tab Tương tác ✅

- [x] **Task 8**: Implement Turbo Stream cho interaction
  - Append interaction mới vào timeline
  - Clear form sau khi submit ✅

## Done Criteria ✅

- [x] Sale có thể xem chi tiết Contact với đầy đủ thông tin
- [x] Sale có thể thêm ghi chú tương tác (call/email/meeting)
- [x] Timeline hiển thị tất cả interactions theo thứ tự mới nhất
- [x] Status progress bar hiển thị đúng trạng thái hiện tại
- [x] Rubocop pass (111 files, no offenses)

## Files Created/Modified

### New Files:
- `db/migrate/20260128144822_create_interactions.rb`
- `app/models/interaction.rb`
- `app/controllers/interactions_controller.rb`
- `app/views/interactions/_interaction.html.erb`
- `app/views/interactions/_form.html.erb`
- `app/views/interactions/_timeline.html.erb`
- `app/views/interactions/create.turbo_stream.erb`
- `app/views/interactions/destroy.turbo_stream.erb`
- `app/views/contacts/partials/_status_progress.html.erb`

### Modified Files:
- `app/models/contact.rb` - Added `has_many :interactions`
- `app/models/ability.rb` - Added interactions mapping
- `app/controllers/contacts_controller.rb` - Load interactions in show
- `config/routes.rb` - Nested interactions routes
- `config/locales/vi.yml` - i18n for interactions
- `app/views/contacts/show.html.erb` - Redesigned per wireframe

## Notes

- Wireframe reference: `docs/ui-design/wireframes/contact_detail.html`
- Related: SRS v3 Section 5.3 (Lịch sử trao đổi)
- Browser test confirmed all features working correctly
