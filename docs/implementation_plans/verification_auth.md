# Verification Plan: Authentication System Tests

## Goal
Verify the UI and logic of the Authentication flow (Login, Logout, Forgot Password) using automated system tests (RSpec + Capybara) since the browser tool is unavailable.

## Configuration Changes
### [MODIFY] [spec/rails_helper.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/spec/rails_helper.rb)
- Uncomment the line loading support files: `Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }`

### [NEW] [spec/support/capybara.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/spec/support/capybara.rb)
- Configure Capybara to use `:selenium_chrome_headless` (or `cuprite` if available, but checking Gemfile shows `selenium-webdriver`).

## Test Cases
### [NEW] [spec/system/authentication_spec.rb](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/spec/system/authentication_spec.rb)
1. **Login Success**:
   - Visit `/users/sign_in`
   - Data: `email` + `password`
   - Action: Click "Đăng nhập"
   - Expect: Redirect to Dashboard, show "Đăng nhập thành công" flash message.

2. **Login Fail**:
   - Visit `/users/sign_in`
   - Data: `email` + `wrong_password`
   - Action: Click "Đăng nhập"
   - Expect: Stay on page, show error message.

3. **Forgot Password**:
   - Visit `/users/sign_in`
   - Click "Quên mật khẩu?" link
   - Expect: Navigate to `/users/password/new`
   - Action: Fill email + Submit
   - Expect: Success message "Bạn sẽ nhận được email..."

4. **Logout**:
   - Login first.
   - Click "Logout" (if available in UI - currently minimal layout might not have it, need to check if Dashboard exists to verify logout link).
   - *Note*: If Dashboard UI isn't built yet, verification might end at "Login success". Mockup `dashboard.html` exists but not implemented in View? TASK-006 Basic UI Layout was done.

## Verification Command
```bash
bundle exec rspec spec/system/authentication_spec.rb
```
