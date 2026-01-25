# TASK-014: Activity Logging Implementation Plan

## Goal
Implement activity logging for authentication events (login, logout, failed login) to track user access.

## Requirements (SRS)
- Log login success (User, IP, User Agent).
- Log login failed (Username/Email, IP).
- Log logout.
- Store changes history (audit trail infrastructure).

## Proposed Changes

### Database
#### [NEW] [db/migrate/timestamp_create_activity_logs.rb]
Create `activity_logs` table:
- `user_id`: bigint (nullable for failed logins)
- `action`: string (login, logout, failed_login)
- `subject_type`: string
- `subject_id`: bigint
- `details`: json (was 'changes' in ERD, but 'details' is more flexible for auth logs)
- `ip_address`: string
- `user_agent`: string

### Models
#### [NEW] [app/models/activity_log.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/app/models/activity_log.rb)
- `belongs_to :user, optional: true`
- `belongs_to :subject, polymorphic: true, optional: true`
- Validations (action presence).

### Configuration
#### [NEW] [config/initializers/warden_hooks.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/config/initializers/warden_hooks.rb)
- Hook into Warden `after_set_user` (Login).
- Hook into Warden `before_logout` (Logout).
- Hook into Warden `before_failure` (Failed Login)? (This is harder with Devise, maybe use `Warden::Manager.before_failure`).

## Verification Plan

### Automated Verification
Create script `tmp/verify_activity_log.rb`:
1. Simulate login (via Warden proxy or manually creating log).
2. Check if log record is created.
3. Verify attributes.

### Manual Verification
1. Login via browser (if fixed) or simulated request.
2. Check `ActivityLog.last` in console.
3. Logout.
4. Check `ActivityLog.last` action is 'logout'.
