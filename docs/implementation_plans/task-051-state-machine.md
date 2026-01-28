# TASK-051: Trạng thái Contact Flow (State Machine)

> **Status**: 🔄 In Progress  
> **Started**: 2026-01-28

## Goal

Implement State Machine cho Contact status theo SRS v3 Section 5.3, đảm bảo chỉ cho phép các transition hợp lệ.

## Phân tích

### Current State (Contact model có sẵn):
```ruby
enum :status, {
  new_contact: 0,       # Mới
  potential: 1,         # Tiềm năng
  in_progress: 2,       # Đang tư vấn
  potential_old: 3,     # Tiềm năng cũ
  closed_new: 4,        # Chốt Mới
  closed_old: 5,        # Chốt Cũ
  failed: 6,            # Thất bại
  cskh_l1: 7,           # CSKH Level 1
  cskh_l2: 8,           # CSKH Level 2
  closed: 9             # Đóng - Kết thúc
}
```

### State Diagram (SRS v3):
```
[*] → Mới (Tổng đài tạo)
Mới → Tiềm_năng (Sale nhận - Pick)
Tiềm_năng → Đang_tư_vấn (Bắt đầu liên hệ)
Tiềm_năng → Tiềm_năng_cũ (Cronjob đầu tháng)
Đang_tư_vấn → Chốt_Mới (Thành công trong tháng)
Đang_tư_vấn → Thất_bại (Không chốt được)
Tiềm_năng_cũ → Chốt_Cũ (Thành công từ tháng trước)
Tiềm_năng_cũ → Thất_bại (Không chốt được)
Thất_bại → CSKH_L1 (Chuyển CSKH)
CSKH_L1 → Chốt_Mới (Chăm sóc thành công)
CSKH_L1 → CSKH_L2 (Tiếp tục)
CSKH_L2 → Đóng (Kết thúc)
```

---

## Tasks

### Phase 1: Backend State Machine

- [ ] **Task 1**: Định nghĩa VALID_TRANSITIONS constant
  - Hash mapping từ status hiện tại → array các status có thể chuyển
  ```ruby
  VALID_TRANSITIONS = {
    new_contact: [:potential],
    potential: [:in_progress, :potential_old, :failed],
    potential_old: [:closed_old, :failed],
    in_progress: [:closed_new, :failed],
    closed_new: [],
    closed_old: [],
    failed: [:cskh_l1],
    cskh_l1: [:closed_new, :cskh_l2],
    cskh_l2: [:closed],
    closed: []
  }.freeze
  ```

- [ ] **Task 2**: Implement `can_transition_to?(new_status)` method
  - Return true/false dựa trên VALID_TRANSITIONS
  - Public method để UI có thể check

- [ ] **Task 3**: Implement `transition_to!(new_status)` method
  - Validate transition
  - Raise error nếu invalid
  - Update status + set timestamps (closed_at khi chuyển sang closed states)
  - Log activity

- [ ] **Task 4**: Implement `available_transitions` method
  - Return array các status có thể chuyển từ current
  - Dùng cho UI dropdown

- [ ] **Task 5**: Thêm validation before_save
  - Chặn update status trực tiếp nếu transition không hợp lệ
  - Bypass khi dùng transition_to!

### Phase 2: Activity Logging

- [ ] **Task 6**: Tạo StatusTransitionLog model (hoặc dùng ActivityLog)
  - contact_id, user_id, from_status, to_status, created_at
  - Optional: reason (text)

- [ ] **Task 7**: Log tự động khi transition
  - After callback trong transition_to!
  - Ghi ai, lúc nào, từ đâu → đâu

### Phase 3: UI - Status Dropdown

- [ ] **Task 8**: Tạo partial `_status_changer.html.erb`
  - Dropdown hiển thị chỉ valid transitions
  - Disable/Hidden nếu không có transition nào
  - Confirmation dialog trước khi chuyển

- [ ] **Task 9**: Controller action `update_status`
  - POST /contacts/:id/update_status
  - Params: new_status, (optional) reason
  - Response: Turbo Stream hoặc redirect

- [ ] **Task 10**: Integrate vào Contact Detail page
  - Thêm dropdown bên cạnh status badge
  - Hoặc trong status progress bar

### Phase 4: Special Cases

- [ ] **Task 11**: Auto-transition khi Pick
  - `assign_to!` đã có: status → potential
  - Đảm bảo dùng transition_to! thay vì update trực tiếp

- [ ] **Task 12**: Cronjob chuyển potential → potential_old
  - Chạy đầu tháng
  - Sidekiq job: PotentialAgingJob
  - Query: status = potential AND created_at < current_month

---

## Test Cases

- [ ] Valid transition → Success
- [ ] Invalid transition (VD: Mới → Chốt) → Error
- [ ] UI chỉ hiện valid options
- [ ] Log ghi nhận mỗi transition
- [ ] Pick auto-transition → potential
- [ ] Cronjob chạy đúng vào đầu tháng

---

## Files To Create/Modify

### New Files:
- `app/models/concerns/status_machine.rb` - State machine concern
- `app/views/contacts/partials/_status_changer.html.erb` - UI dropdown
- `app/views/contacts/update_status.turbo_stream.erb` - Turbo response
- `app/jobs/potential_aging_job.rb` - Cronjob đầu tháng

### Modified Files:
- `app/models/contact.rb` - Include StatusMachine concern
- `app/controllers/contacts_controller.rb` - Add update_status action
- `config/routes.rb` - Add update_status route
- `app/views/contacts/show.html.erb` - Add status changer UI

---

## Done Criteria

- [ ] Chỉ cho phép valid transitions
- [ ] UI dropdown hiển thị đúng options
- [ ] Mỗi transition được log
- [ ] Pick tự động chuyển → Tiềm năng
- [ ] Cronjob chuyển Tiềm năng cũ hoạt động
- [ ] Rubocop pass
- [ ] RSpec tests pass

---

## Notes

- Tham khảo: SRS v3 Section 5.3 (State Diagram)
- Related: TASK-023 (Status Progress Bar) - đã implement
- Gem option: `aasm` hoặc `state_machines` - Recommend: implement manually (simple enough)
