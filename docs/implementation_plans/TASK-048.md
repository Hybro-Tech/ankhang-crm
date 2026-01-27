# Implementation Plan - TASK-048: Saturday Work Schedule Management

## 1. Goal
Allow Admins to manage Saturday work schedules for employees. This data is critical for the Smart Routing system to correctly route leads on Saturdays only to those who are actually working.

## 2. Requirements
- **Data Structure**:
  - `SaturdaySchedule`: Stores the specific Saturday date and an optional description.
  - `SaturdayScheduleUser`: Join table linking `SaturdaySchedule` to `User`.
- **Logic**:
  - Validation: The selected date MUST be a Saturday.
  - Validation: Uniqueness (only one schedule record per date).
- **UI**:
  - List view of upcoming Saturday schedules.
  - Create/Edit form: Date picker (restricted/validated to Saturdays) + Checkbox list of active employees.
  - Calendar view integration (optional/nice-to-have later).

## 3. Architecture & Components

### Database Schema
```ruby
create_table :saturday_schedules do |t|
  t.date :date, null: false, index: { unique: true }
  t.string :description
  t.timestamps
end

create_table :saturday_schedule_users do |t|
  t.references :saturday_schedule, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.timestamps
end
# Add composite index for uniqueness: [:saturday_schedule_id, :user_id]
```

### Models
- `SaturdaySchedule`
  - `has_many :saturday_schedule_users, dependent: :destroy`
  - `has_many :users, through: :saturday_schedule_users`
  - Validations: presence of date, uniqueness of date, custom validation "must be saturday".
- `SaturdayScheduleUser`
  - `belongs_to :saturday_schedule`
  - `belongs_to :user`

### Controllers
- `SaturdaySchedulesController` (Standard CRUD)
  - `index`: List upcoming/past schedules.
  - `new/create`: Form to pick date + users.
  - `edit/update`: Modify users list.
  - `destroy`: Remove schedule.

### Views
- `index.html.erb`: Table listing dates and headcount.
- `_form.html.erb`: 
  - Date input.
  - List of Users with checkboxes (grouped by Team for better UX).

## 4. Step-by-Step Implementation

### Phase 1: Models & Database
1. Create migration for `saturday_schedules` and join table.
2. Implement `SaturdaySchedule` model with validations.
3. Update `User` model (`has_many :saturday_schedules...`).
4. Add model specs (RSpec).

### Phase 2: Controllers & Routes
1. Add `resources :saturday_schedules`.
2. Implement Controller with Strong Params (accepting `user_ids: []`).
3. Add Request specs.

### Phase 3: UI Implementation
1. Create `index` view.
2. Create `new/edit` form with User selection logic (Group by Team).
3. Apply Tailwind styling consistent with Holidays UI.

### Phase 4: Verification
1. Run Rubocop.
2. Run RSpec.
3. Manual verification via Browser.

## 5. Security & Permissions
- `Ability.rb`: Only Admins (or roles with `saturday_schedules.manage` permission) can CRUD.
- Everyone can view? (Maybe restricts to Admin/Manager for now).

## 6. Questions/Edge Cases
- **Q**: What if a user is deleted? **A**: Join record destroyed automatically.
- **Q**: Recurring schedule? **A**: Out of scope for now, manual creation week-by-week.
