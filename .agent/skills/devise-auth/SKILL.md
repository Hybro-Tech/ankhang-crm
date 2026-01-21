---
name: devise-auth
description: Devise authentication patterns for Rails. Session management, password recovery, 2FA preparation.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Devise Authentication

> **Authentication done right.** Devise for Rails.
> Session management, Remember me, Password reset.

---

## 🎯 Core Modules

| Module | Purpose |
|--------|---------|
| `database_authenticatable` | Password hashing, login |
| `registerable` | User registration |
| `recoverable` | Password reset via email |
| `rememberable` | "Remember me" sessions |
| `trackable` | Sign in count, timestamps, IPs |
| `validatable` | Email/password validations |
| `timeoutable` | Session timeout |
| `lockable` | Lock after failed attempts |

---

## 🔧 Setup for AnKhangCRM

```ruby
# Gemfile
gem 'devise'

# Terminal
rails generate devise:install
rails generate devise User
rails db:migrate
```

### User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :timeoutable,
         :lockable

  # Relationships
  has_many :user_roles
  has_many :roles, through: :user_roles
  belongs_to :team, optional: true

  # AnKhangCRM specific
  enum status: { active: 0, locked: 1 }

  def timeout_in
    3.days # SRS: AUTH-006
  end
end
```

---

## 🔐 Controller Setup

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone])
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_out_path_for(resource)
    new_user_session_path
  end
end
```

---

## 🛡️ Security Configuration

```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  # Password requirements (SRS: 8+ chars)
  config.password_length = 8..128

  # Session timeout (SRS: 3 days)
  config.timeout_in = 3.days

  # Remember me duration (SRS: 30 days)
  config.remember_for = 30.days

  # Lock after failed attempts (SRS: Rate limiting)
  config.lock_strategy = :failed_attempts
  config.maximum_attempts = 5
  config.unlock_strategy = :time
  config.unlock_in = 15.minutes

  # Stretches for bcrypt (SRS: cost 12)
  config.stretches = 12

  # Reset password expiry (SRS: 1 hour)
  config.reset_password_within = 1.hour
end
```

---

## 📧 Password Reset

```ruby
# app/views/devise/mailers/reset_password_instructions.html.erb
<p>Xin chào <%= @resource.name %>,</p>
<p>Bạn nhận được email này vì có yêu cầu đặt lại mật khẩu.</p>
<p><%= link_to 'Đặt lại mật khẩu', edit_password_url(@resource, reset_password_token: @token) %></p>
<p>Link này sẽ hết hạn sau 1 giờ.</p>
```

---

## 🎨 Custom Views

```bash
# Generate customizable views
rails generate devise:views

# Views structure
app/views/devise/
├── sessions/
│   └── new.html.erb       # Login page
├── passwords/
│   ├── new.html.erb       # Forgot password
│   └── edit.html.erb      # Reset password
└── shared/
    └── _links.html.erb    # Navigation links
```

---

## 🔒 Protecting Controllers

```ruby
# Admin-only controller
class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    unless current_user.has_role?(:super_admin)
      redirect_to root_path, alert: "Bạn không có quyền truy cập."
    end
  end
end
```

---

## 📝 Audit Logging

```ruby
# Track login events for Audit Trail
class Users::SessionsController < Devise::SessionsController
  after_action :log_sign_in, only: :create
  after_action :log_sign_out, only: :destroy

  private

  def log_sign_in
    ActivityLog.create!(
      user: current_user,
      action: 'login',
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  def log_sign_out
    ActivityLog.create!(
      user: current_user,
      action: 'logout',
      ip_address: request.remote_ip
    )
  end
end
```

---

## 🔮 2FA Preparation (Phase 2)

```ruby
# Gemfile (for Phase 2)
gem 'devise-two-factor'
gem 'rqrcode' # QR code generation

# Model addition
class User < ApplicationRecord
  devise :two_factor_authenticatable,
         :two_factor_backupable,
         otp_backup_code_length: 10,
         otp_number_of_backup_codes: 10
end
```

---

## ❌ Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Skip CSRF protection | Keep default enabled |
| Store password in plain text | Use Devise hashing |
| Skip timeout for admin | Apply timeout to all |
| Log passwords | Never log sensitive data |
| Custom auth logic | Extend Devise controllers |

---

## ✅ Checklist

- [ ] Devise installed and configured?
- [ ] Session timeout set (3 days)?
- [ ] Password requirements enforced?
- [ ] Password reset email working?
- [ ] Failed login lockout enabled?
- [ ] Audit logging for auth events?
