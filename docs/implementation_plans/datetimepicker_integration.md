# Implementation Plan - Datetimepicker Integration

Refactor all date and datetime inputs to use a unified `datetimepicker` (Flatpickr) via Stimulus.
File location: `docs/implementation_plans/datetimepicker_integration.md`

## User Review Required
> [!IMPORTANT]
> - I will be using **Flatpickr** as the datetime picker library.
> - I will use `input type="text"` instead of `date`/`datetime-local`.
> - Visual style: Tailwind CSS classes to match existing design.

## Proposed Changes

### JavaScript / Stimulus
#### [NEW] [app/javascript/controllers/datepicker_controller.js](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/app/javascript/controllers/datepicker_controller.js)
- Create a new Stimulus controller.
- Initialize Flatpickr on `connect()`.
- Import Vietnamese locale.

### Configuration
#### [MODIFY] [config/importmap.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/config/importmap.rb)
- Pin `flatpickr`
- Pin `flatpickr/dist/l10n/vn.js`

### Views
Search and replace:
- `f.date_field` -> `f.text_field` + `data-controller="datepicker"`
- `f.datetime_field` -> `f.text_field` + `data-controller="datepicker" data-datepicker-enable-time-value="true"`
- `type="date"` -> `type="text"` + controller

**Target Files (Preliminary):**
- `app/views/holidays/_form.html.erb`
- [Other files found via search]

## Verification Plan
1.  **Manual Verification**:
    -   Go to Holidays -> New.
    -   Click "Ngày".
    -   Verify Flatpickr opens with VN locale.
    -   Submit and verify.
