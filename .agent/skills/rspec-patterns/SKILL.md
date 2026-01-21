---
name: rspec-patterns
description: RSpec Rails testing patterns and best practices. BDD, factories, system tests, mocking.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# RSpec Patterns

> **Behavior-Driven Development for Rails.**
> Tests as documentation. BetterSpecs guidelines.

---

## 🎯 Core Philosophy

| Principle | Meaning |
|-----------|---------|
| **Test First** | Write tests before implementation |
| **Behavior Focus** | Test what it does, not how |
| **Fast Feedback** | Quick test runs, parallel execution |
| **Living Documentation** | Tests explain the system |

---

## 📁 Test Structure

```
spec/
├── models/          # Unit tests for models
├── requests/        # API/controller tests (preferred)
├── system/          # End-to-end browser tests
├── services/        # Service object tests
├── jobs/            # Background job tests
├── factories/       # FactoryBot definitions
├── support/         # Shared helpers, configs
└── rails_helper.rb  # Rails-specific setup
```

---

## 🏗️ Test Pyramid

```
        /\           System Tests (few)
       /  \          Critical user flows
      /----\
     /      \        Request Tests (some)
    /--------\       API, controllers
   /          \
  /------------\     Model/Unit Tests (many)
                     Business logic, validations
```

---

## ✍️ Writing Good Specs

### Describe & Context

```ruby
RSpec.describe Contact, type: :model do
  describe "#pick" do
    context "when contact is new" do
      it "assigns to sales user" do
        # test
      end
    end

    context "when contact already picked" do
      it "raises AlreadyPickedError" do
        # test
      end
    end
  end
end
```

### Naming Conventions

| Element | Convention |
|---------|------------|
| Class methods | `.method_name` |
| Instance methods | `#method_name` |
| `describe` | Group by class/method |
| `context` | Different scenarios |
| `it` | Specific behavior (< 40 chars) |

### Single Expectation

```ruby
# Good - one expectation per test
it "returns the contact name" do
  expect(contact.name).to eq("John")
end

# Integration tests - multiple OK if related
it "creates contact and sends notification" do
  expect { service.call }.to change(Contact, :count).by(1)
    .and change(Notification, :count).by(1)
end
```

---

## 🏭 FactoryBot Patterns

### Basic Factory

```ruby
# spec/factories/contacts.rb
FactoryBot.define do
  factory :contact do
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
    status { :new }

    trait :picked do
      status { :picked }
      assignee { association :user, :sales }
      picked_at { Time.current }
    end

    trait :closed do
      status { :closed }
    end
  end
end
```

### Usage

```ruby
# Basic creation
contact = create(:contact)

# With traits
picked_contact = create(:contact, :picked)

# With overrides
contact = create(:contact, name: "Test User", status: :active)

# Build (no DB save)
contact = build(:contact)

# Build list
contacts = create_list(:contact, 5)
```

---

## 📝 Model Specs

```ruby
RSpec.describe Contact, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:phone) }
    it { should validate_uniqueness_of(:phone) }
  end

  describe "associations" do
    it { should belong_to(:assignee).class_name("User").optional }
    it { should have_many(:deals) }
    it { should have_many(:activity_logs) }
  end

  describe "scopes" do
    describe ".available" do
      it "returns only new contacts" do
        new_contact = create(:contact, status: :new)
        picked_contact = create(:contact, :picked)

        expect(Contact.available).to contain_exactly(new_contact)
      end
    end
  end
end
```

---

## 🌐 Request Specs (Controller Tests)

```ruby
RSpec.describe "Contacts", type: :request do
  let(:user) { create(:user, :sales) }

  before { sign_in user }

  describe "GET /contacts" do
    it "returns success" do
      get contacts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /contacts/:id/pick" do
    let(:contact) { create(:contact) }

    it "picks the contact" do
      post contact_pick_path(contact)

      expect(response).to redirect_to(contacts_path)
      expect(contact.reload.assignee).to eq(user)
    end

    context "when in cooldown" do
      before { user.update!(last_pick_at: 1.minute.ago) }

      it "rejects the pick" do
        post contact_pick_path(contact)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

---

## 🖥️ System Specs (E2E)

```ruby
RSpec.describe "Contact Pick Flow", type: :system do
  let(:sales_user) { create(:user, :sales) }
  let!(:contact) { create(:contact) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in sales_user
  end

  it "allows sales to pick available contact" do
    visit contacts_path

    within("##{dom_id(contact)}") do
      click_button "Nhận khách"
    end

    expect(page).to have_content("Đã nhận khách hàng!")
    expect(page).to have_content("Đã được nhận bởi #{sales_user.name}")
  end
end
```

---

## 🎭 Mocking & Stubbing

### When to Mock

| Mock | Don't Mock |
|------|------------|
| External APIs | Domain logic |
| Time-sensitive | Simple dependencies |
| Expensive operations | The code under test |
| Third-party services | Database (use factories) |

### Examples

```ruby
# Stub external service
allow(ZaloService).to receive(:send_message).and_return(true)

# Mock with expectations
expect(NotificationJob).to receive(:perform_later).with(contact.id)

# Freeze time
travel_to Time.zone.local(2026, 1, 21, 9, 0, 0) do
  expect(contact.created_today?).to be true
end
```

---

## 🔧 Shared Examples

```ruby
# spec/support/shared_examples/trackable.rb
RSpec.shared_examples "trackable" do
  it "creates activity log on save" do
    expect { subject.save }.to change(ActivityLog, :count).by(1)
  end
end

# Usage
RSpec.describe Contact, type: :model do
  it_behaves_like "trackable"
end
```

---

## ⚡ Performance Tips

| Tip | How |
|-----|-----|
| Use `let` over `before` | Lazy evaluation |
| Prefer `build` over `create` | Skip DB when possible |
| Use `--profile` | Find slow tests |
| Parallel tests | `parallel_tests` gem |
| Use `aggregate_failures` | Report all failures at once |

---

## ❌ Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Test implementation | Test behavior |
| Shared state between tests | Independent tests |
| Complex setup | Simplify or extract |
| Random data without seed | Use `Faker` with seed |
| Skip cleanup | Use `DatabaseCleaner` |
| Ignore flaky tests | Fix root cause |

---

## ✅ Checklist

- [ ] Tests describe behavior?
- [ ] Factories used (not fixtures)?
- [ ] Edge cases covered?
- [ ] No shared state?
- [ ] Fast execution?
- [ ] CI passing?
