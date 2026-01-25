# TASK-014b: Configure I18n & Default Locale

## Goal
Set the default system language to Vietnamese (vi) as requested by the user.

## Proposed Changes

### Configuration
#### [MODIFY] [config/application.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/config/application.rb)
- Set `config.i18n.default_locale = :vi`.
- Ensure `config.i18n.available_locales = [:en, :vi]`.

### Tests
#### [MODIFY] [spec/system/authentication_spec.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/spec/system/authentication_spec.rb)
- Update expected flash messages to Vietnamese:
    - "Signed in successfully." -> "Đăng nhập thành công."
    - "Invalid Email or password." -> "Email hoặc mật khẩu không đúng."
    - "You will receive an email..." -> "Bạn sẽ nhận được email hướng dẫn đặt lại mật khẩu trong vài phút."

## Verification Plan

### Automated Verification
- Run `bundle exec rspec spec/system/authentication_spec.rb`
- Expect all tests to PASS with Vietnamese messages.

### Manual Verification
- User refreshes browser to see Vietnamese messages on Login/Logout.
