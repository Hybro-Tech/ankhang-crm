---
name: rails-patterns
description: Ruby on Rails 7+ patterns, conventions, and best practices. MVC architecture, ActiveRecord, Concerns, Service Objects.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Rails Patterns

> **Ruby on Rails 7+ best practices for 2025.**
> Convention over Configuration. Learn to THINK the Rails way.

---

## 🎯 Core Philosophy

| Principle | Meaning |
|-----------|---------|
| **Convention over Configuration** | Follow Rails defaults, don't fight the framework |
| **DRY** | Don't Repeat Yourself |
| **Fat Model, Skinny Controller** | Business logic in models, controllers stay lean |
| **Boring REST** | Standard CRUD, conventional routing |
| **Explicit > Implicit** | Clear code over "magic" when debugging matters |

---

## 📁 Project Structure

```
app/
├── controllers/     # Handle HTTP, delegate to models/services
├── models/          # Business logic, validations, associations
│   └── concerns/    # Shared model behaviors
├── views/           # ERB templates, partials
├── helpers/         # View helpers (keep minimal)
├── services/        # Complex business operations (optional)
├── jobs/            # Background jobs (Sidekiq)
├── mailers/         # Email logic
└── components/      # ViewComponent (recommended)
```

---

## 🏗️ Model Patterns

### ActiveRecord Best Practices

| Pattern | Example |
|---------|---------|
| **Scopes** | `scope :active, -> { where(status: 'active') }` |
| **Validations** | `validates :email, presence: true, uniqueness: true` |
| **Callbacks** | Use sparingly, prefer explicit service calls |
| **Enums** | `enum status: { pending: 0, active: 1, closed: 2 }` |

### Concerns (Shared Behaviors)

```ruby
# app/models/concerns/trackable.rb
module Trackable
  extend ActiveSupport::Concern

  included do
    has_many :activity_logs, as: :trackable
    after_save :log_changes
  end

  def log_changes
    # Audit trail logic
  end
end
```

### When to Use Service Objects

| Use Service | Use Model Method |
|-------------|------------------|
| Involves multiple models | Single model operation |
| External API calls | Internal validations |
| Complex transaction | Simple CRUD |
| Needs explicit error handling | Standard ActiveRecord |

```ruby
# app/services/contacts/pick_service.rb
module Contacts
  class PickService
    def initialize(contact:, sales_user:)
      @contact = contact
      @sales_user = sales_user
    end

    def call
      return failure(:cooldown) if @sales_user.in_cooldown?
      return failure(:already_picked) if @contact.picked?

      ActiveRecord::Base.transaction do
        @contact.update!(
          status: :picked,
          assignee: @sales_user,
          picked_at: Time.current
        )
        @sales_user.update!(last_pick_at: Time.current)
      end

      success(@contact)
    rescue ActiveRecord::RecordInvalid => e
      failure(:invalid, e.message)
    end

    private

    def success(data) = { success: true, data: data }
    def failure(code, msg = nil) = { success: false, error: code, message: msg }
  end
end
```

---

## 🎮 Controller Patterns

### Boring REST (Preferred)

```ruby
# Standard 7 actions only: index, show, new, create, edit, update, destroy
class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @contacts = Contact.accessible_by(current_ability).page(params[:page])
  end

  def show; end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to @contact, notice: 'Contact created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name, :phone, :email, :source)
  end
end
```

### Non-CRUD Actions → Nested Controllers

```ruby
# Instead of: POST /contacts/:id/pick
# Create: app/controllers/contacts/picks_controller.rb
module Contacts
  class PicksController < ApplicationController
    def create
      result = Contacts::PickService.new(
        contact: Contact.find(params[:contact_id]),
        sales_user: current_user
      ).call

      if result[:success]
        redirect_to contacts_path, notice: 'Đã nhận khách hàng!'
      else
        redirect_to contacts_path, alert: result[:message]
      end
    end
  end
end

# routes.rb
resources :contacts do
  resource :pick, only: [:create], module: :contacts
end
```

---

## 🔒 Authorization with CanCanCan

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Load dynamic permissions from database
    user.roles.each do |role|
      role.permissions.each do |perm|
        can perm.action.to_sym, perm.subject.constantize
      end
    end

    # User-level overrides
    user.user_permissions.each do |up|
      if up.granted
        can up.permission.action.to_sym, up.permission.subject.constantize
      else
        cannot up.permission.action.to_sym, up.permission.subject.constantize
      end
    end
  end
end
```

---

## 🛡️ Security Patterns

| Pattern | Implementation |
|---------|----------------|
| **Strong Parameters** | Always use `params.require().permit()` |
| **CSRF Protection** | Default enabled, don't skip |
| **SQL Injection** | Use parameterized queries, avoid string interpolation |
| **Mass Assignment** | Whitelist attributes explicitly |
| **Credentials** | Use `Rails.application.credentials` |

---

## ⚡ Performance

| Pattern | Tip |
|---------|-----|
| **N+1 Queries** | Use `includes()`, add Bullet gem |
| **Counter Cache** | `counter_cache: true` for counts |
| **Database Indexes** | Add indexes for foreign keys, search columns |
| **Fragment Caching** | Cache expensive partials |
| **Background Jobs** | Move slow operations to Sidekiq |

---

## ❌ Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Fat controllers | Move logic to models/services |
| Callbacks for complex logic | Explicit service calls |
| `find_by_sql` everywhere | Use ActiveRecord query methods |
| Skip validations | Fix the data model |
| `rescue Exception` | Rescue specific errors |
| Business logic in views | Use helpers or presenters |

---

## ✅ Checklist Before Commit

- [ ] Follows Rails conventions?
- [ ] Strong parameters defined?
- [ ] Validations in place?
- [ ] Database indexes added?
- [ ] Tests written?
- [ ] No N+1 queries? (check with Bullet)
