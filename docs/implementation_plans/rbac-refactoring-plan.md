# RBAC Refactoring Implementation Plan

> **Version:** 1.0
> **Created:** 2026-01-29
> **Status:** PENDING REVIEW

---

## 1. Mục Tiêu

Refactor hệ thống phân quyền (RBAC) để:
1. Loại bỏ hardcoded role codes
2. Thêm authorization cho các endpoints còn thiếu
3. Thêm model validations
4. Cải thiện error handling
5. Viết thêm RSpec tests

---

## 2. Tổng Quan Vấn Đề

### 2.1 Thống Kê
| Mức độ | Số lượng |
|--------|----------|
| 🔴 P0 - Critical | 15 |
| 🟠 P1 - High | 5 |
| 🟡 P2 - Medium | 6 |
| 🟢 P3 - Low | 4 |
| **TỔNG** | **30** |

### 2.2 Rủi Ro Chính
- Nếu admin thay đổi role code → Smart Routing và Notifications **HỎNG**
- Một số endpoints có thể bị bypass authorization
- Duplicate records có thể được tạo do thiếu validation

---

## 3. Proposed Changes

### Phase 1: Role Constants (P0)

#### [NEW] app/models/concerns/role_codes.rb
Tạo concern chứa constants cho role codes:
```ruby
module RoleCodes
  SUPER_ADMIN = "super_admin"
  SALE = "sale"
  CALL_CENTER = "call_center"
  CSKH = "cskh"
  
  ALL = [SUPER_ADMIN, SALE, CALL_CENTER, CSKH].freeze
end
```

#### [MODIFY] app/models/role.rb
Include `RoleCodes` concern.

---

### Phase 2: Model Validations (P0)

#### [MODIFY] app/models/role_permission.rb
Thêm uniqueness validation:
```ruby
validates :role_id, uniqueness: { scope: :permission_id }
```

#### [MODIFY] app/models/user_role.rb
Thêm uniqueness validation:
```ruby
validates :user_id, uniqueness: { scope: :role_id }
```

---

### Phase 3: Service Objects Refactoring (P0)

#### [MODIFY] app/services/smart_routing_service.rb
- Line 143: Đổi `Role.find_by(code: "sale")` → `Role.find_by(code: Role::SALE)`
- Line 179: Đổi `Role.find_by(code: "sale")` → `Role.find_by(code: Role::SALE)`

#### [MODIFY] app/services/notification_service.rb
- Line 48: Đổi `where(roles: { code: "sale" })` → `where(roles: { code: Role::SALE })`

---

### Phase 4: Controller Authorization (P0/P1)

#### [MODIFY] app/controllers/contacts_controller.rb
- Thêm `authorize! :create, Contact` cho `check_phone` action
- Thêm `authorize! :create, Contact` cho `check_identity` action
- Thêm `authorize! :read, Contact` cho `recent` action

#### [MODIFY] app/controllers/sales_workspace_controller.rb
- Đổi `has_role_code?("sale")` → `sale_staff?` (đã có sẵn method)
- Hoặc đổi sang dùng CanCanCan: `authorize! :view_sales, :dashboards`

#### [MODIFY] app/controllers/dashboard_controller.rb
- Thêm `authorize! :read, :dashboards` cho `index` action

#### [MODIFY] app/controllers/notifications_controller.rb
- Thêm `before_action -> { authorize! :read, Notification }`

---

### Phase 5: Helper Refactoring (P0)

#### [MODIFY] app/helpers/roles_helper.rb
Đổi từ check `role.code` sang `role.dashboard_type`:
```ruby
def role_icon_bg_class(role)
  case role.dashboard_type
  when "admin" then "bg-red-100 text-red-600"
  when "sale" then "bg-green-100 text-green-600"
  when "call_center" then "bg-purple-100 text-purple-600"
  when "cskh" then "bg-teal-100 text-teal-600"
  else "bg-gray-100 text-gray-600"
  end
end
```

---

### Phase 6: Ability Error Handling (P1)

#### [MODIFY] app/models/ability.rb
Thêm error handling cho `parse_permission_code`:
```ruby
def parse_permission_code(code)
  parts = code.to_s.split(".", 2)
  return nil unless parts.size == 2
  [parts[0].to_sym, parts[1].to_sym]
end

def apply_permission(perm)
  parsed = parse_permission_code(perm.code)
  return unless parsed
  # ... rest of logic
end
```

---

### Phase 7: RSpec Tests (NEW)

#### [NEW] spec/models/role_permission_spec.rb
Test uniqueness validation.

#### [NEW] spec/models/user_role_spec.rb
Test uniqueness validation.

#### [NEW] spec/services/smart_routing_service_spec.rb
Test routing logic với role constants.

#### [NEW] spec/services/notification_service_spec.rb
Test notification creation.

#### [MODIFY] spec/controllers/contacts_controller_spec.rb
Test authorization cho `check_phone`, `check_identity`.

#### [MODIFY] spec/models/ability_spec.rb
Test error handling cho invalid permission codes.

---

## 4. Verification Plan

### 4.1 Automated Tests

#### RSpec Tests (Existing)
```bash
# Chạy tất cả tests liên quan đến RBAC
docker compose exec app bundle exec rspec spec/models/ability_spec.rb
docker compose exec app bundle exec rspec spec/controllers/sales_workspace_controller_spec.rb
docker compose exec app bundle exec rspec spec/controllers/dashboard_controller_spec.rb
```

#### RSpec Tests (New - sẽ viết)
```bash
# Model validations
docker compose exec app bundle exec rspec spec/models/role_permission_spec.rb
docker compose exec app bundle exec rspec spec/models/user_role_spec.rb

# Services
docker compose exec app bundle exec rspec spec/services/smart_routing_service_spec.rb
docker compose exec app bundle exec rspec spec/services/notification_service_spec.rb
```

#### Rubocop
```bash
docker compose exec app bundle exec rubocop --format simple
docker compose exec app bundle exec rubocop -A  # Auto-fix
```

#### Full Test Suite
```bash
docker compose exec app bundle exec rspec
```

### 4.2 Manual Testing Scenarios

#### Scenario 1: Role Constants (sau Phase 1-3)
1. Đăng nhập với account `tongdai1@ankhang.test` / `Tongdai@123`
2. Tạo một Contact mới
3. Verify: Contact được tạo thành công và Smart Routing hoạt động (có notification cho Sale)

#### Scenario 2: Authorization Endpoints (sau Phase 4)
1. Đăng nhập với account `sale.hn1@ankhang.test` / `Sale@123`
2. Truy cập `/contacts/check_phone?phone=0123456789`
3. **Expected:** Trả về 403 Forbidden (vì Sale không có quyền `contacts.create`)

4. Đăng nhập lại với `tongdai1@ankhang.test`
5. Truy cập `/contacts/check_phone?phone=0123456789`
6. **Expected:** Trả về JSON response (Tổng Đài có quyền `contacts.create`)

#### Scenario 3: Model Validations (sau Phase 2)
1. Mở Rails console: `docker compose exec app rails c`
2. Thử tạo duplicate RolePermission:
```ruby
role = Role.first
perm = Permission.first
RolePermission.create!(role: role, permission: perm)
RolePermission.create!(role: role, permission: perm)  # Should raise error
```
3. **Expected:** Lần thứ 2 raise `ActiveRecord::RecordInvalid`

#### Scenario 4: Helper Icons (sau Phase 5)
1. Đăng nhập với `admin@ankhang.test` / `Admin@123`
2. Vào `/roles`
3. **Expected:** Mỗi role hiển thị đúng icon và màu sắc

### 4.3 RSpec Test Cases Chi Tiết

#### Phase 1: Role Constants Tests
**File:** `spec/models/concerns/role_codes_spec.rb`
```ruby
RSpec.describe RoleCodes do
  describe "constants" do
    it "defines SUPER_ADMIN constant" do
      expect(Role::SUPER_ADMIN).to eq("super_admin")
    end
    
    it "defines SALE constant" do
      expect(Role::SALE).to eq("sale")
    end
    
    it "defines CALL_CENTER constant" do
      expect(Role::CALL_CENTER).to eq("call_center")
    end
    
    it "defines CSKH constant" do
      expect(Role::CSKH).to eq("cskh")
    end
    
    it "defines ALL array with all codes" do
      expect(Role::ALL_CODES).to contain_exactly(
        "super_admin", "sale", "call_center", "cskh"
      )
    end
  end
end
```

---

#### Phase 2: Model Validations Tests
**File:** `spec/models/role_permission_spec.rb`
```ruby
RSpec.describe RolePermission, type: :model do
  describe "validations" do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }
    
    it "allows creating a role_permission" do
      rp = RolePermission.new(role: role, permission: permission)
      expect(rp).to be_valid
    end
    
    it "does not allow duplicate role-permission combination" do
      RolePermission.create!(role: role, permission: permission)
      duplicate = RolePermission.new(role: role, permission: permission)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:role_id]).to include("has already been taken")
    end
    
    it "allows same permission for different roles" do
      other_role = create(:role)
      RolePermission.create!(role: role, permission: permission)
      
      other_rp = RolePermission.new(role: other_role, permission: permission)
      expect(other_rp).to be_valid
    end
  end
end
```

**File:** `spec/models/user_role_spec.rb`
```ruby
RSpec.describe UserRole, type: :model do
  describe "validations" do
    let(:user) { create(:user) }
    let(:role) { create(:role) }
    
    it "allows creating a user_role" do
      ur = UserRole.new(user: user, role: role)
      expect(ur).to be_valid
    end
    
    it "does not allow duplicate user-role combination" do
      UserRole.create!(user: user, role: role)
      duplicate = UserRole.new(user: user, role: role)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end
    
    it "allows same role for different users" do
      other_user = create(:user)
      UserRole.create!(user: user, role: role)
      
      other_ur = UserRole.new(user: other_user, role: role)
      expect(other_ur).to be_valid
    end
  end
end
```

---

#### Phase 3: Services Tests
**File:** `spec/services/smart_routing_service_spec.rb`
```ruby
RSpec.describe SmartRoutingService do
  let(:team) { create(:team) }
  let(:service_type) { create(:service_type, team: team) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }
  let(:sale_user) { create(:user, roles: [sale_role], teams: [team]) }
  
  describe ".initialize_visibility" do
    context "when smart routing is enabled" do
      let(:contact) { create(:contact, service_type: service_type, status: :new_contact) }
      
      before do
        allow(Setting).to receive(:within_working_hours?).and_return(true)
        service_type.update!(use_smart_routing: true)
      end
      
      it "assigns visibility to first sale in team" do
        result = SmartRoutingService.initialize_visibility(contact)
        
        expect(result).to be true
        expect(contact.reload.visible_to_user_ids).to include(sale_user.id)
      end
    end
    
    context "when smart routing is disabled" do
      let(:contact) { create(:contact, service_type: service_type, status: :new_contact) }
      
      before do
        service_type.update!(use_smart_routing: false)
      end
      
      it "notifies all sales in team (pool mode)" do
        SmartRoutingService.initialize_visibility(contact)
        
        # Pool mode = visible_to_user_ids contains all sales
        expect(contact.reload.visible_to_user_ids).to include(sale_user.id)
      end
    end
  end
  
  describe ".visible_to?" do
    let(:contact) { create(:contact, service_type: service_type) }
    
    it "returns true when contact is in pool mode" do
      contact.update!(visible_to_user_ids: nil)
      
      expect(SmartRoutingService.visible_to?(contact, sale_user)).to be true
    end
    
    it "returns true when user is in visibility list" do
      contact.update!(visible_to_user_ids: [sale_user.id])
      
      expect(SmartRoutingService.visible_to?(contact, sale_user)).to be true
    end
    
    it "returns false when user is not in visibility list" do
      other_user = create(:user, roles: [sale_role])
      contact.update!(visible_to_user_ids: [other_user.id])
      
      expect(SmartRoutingService.visible_to?(contact, sale_user)).to be false
    end
  end
end
```

**File:** `spec/services/notification_service_spec.rb`
```ruby
RSpec.describe NotificationService do
  let(:user) { create(:user) }
  let(:contact) { create(:contact) }
  
  describe ".notify" do
    it "creates a notification for user" do
      expect {
        NotificationService.notify(
          user: user,
          type: "contact_created",
          notifiable: contact
        )
      }.to change(Notification, :count).by(1)
    end
    
    it "sets correct notification attributes" do
      NotificationService.notify(
        user: user,
        type: "contact_created",
        notifiable: contact,
        title: "Test Title",
        body: "Test Body"
      )
      
      notification = Notification.last
      expect(notification.user).to eq(user)
      expect(notification.notification_type).to eq("contact_created")
      expect(notification.notifiable).to eq(contact)
      expect(notification.title).to eq("Test Title")
    end
  end
  
  describe ".notify_contact_created" do
    let(:team) { create(:team) }
    let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE) }
    let(:sale_user) { create(:user, roles: [sale_role], teams: [team]) }
    let(:contact) { create(:contact, team: team, visible_to_user_ids: [sale_user.id]) }
    
    it "notifies users in visibility list" do
      expect {
        NotificationService.notify_contact_created(contact)
      }.to change { Notification.where(user: sale_user).count }.by(1)
    end
  end
end
```

---

#### Phase 4: Controller Authorization Tests
**File:** `spec/controllers/contacts_controller_spec.rb` (thêm vào)
```ruby
RSpec.describe ContactsController, type: :controller do
  include Devise::Test::ControllerHelpers
  
  let(:tongdai_role) { Role.find_by(name: "Tổng Đài") || create(:role, name: "Tổng Đài") }
  let(:sale_role) { Role.find_by(name: "Sale") || create(:role, name: "Sale") }
  
  describe "GET #check_phone" do
    context "when user has contacts.create permission" do
      let(:user) { create(:user, roles: [tongdai_role]) }
      
      before do
        # Ensure permission exists
        Permission.find_or_create_by!(code: "contacts.create")
        tongdai_role.permissions << Permission.find_by(code: "contacts.create")
        sign_in user
      end
      
      it "returns success" do
        get :check_phone, params: { phone: "0123456789" }
        expect(response).to have_http_status(:success)
      end
    end
    
    context "when user lacks contacts.create permission" do
      let(:user) { create(:user, roles: [sale_role]) }
      
      before { sign_in user }
      
      it "raises CanCan::AccessDenied" do
        expect {
          get :check_phone, params: { phone: "0123456789" }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
  
  describe "GET #check_identity" do
    context "when user has contacts.create permission" do
      let(:user) { create(:user, roles: [tongdai_role]) }
      
      before do
        Permission.find_or_create_by!(code: "contacts.create")
        tongdai_role.permissions << Permission.find_by(code: "contacts.create")
        sign_in user
      end
      
      it "returns success" do
        get :check_identity, params: { identity: "123456789" }
        expect(response).to have_http_status(:success)
      end
    end
    
    context "when user lacks contacts.create permission" do
      let(:user) { create(:user, roles: [sale_role]) }
      
      before { sign_in user }
      
      it "raises CanCan::AccessDenied" do
        expect {
          get :check_identity, params: { identity: "123456789" }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
```

**File:** `spec/controllers/sales_workspace_controller_spec.rb` (thêm vào)
```ruby
describe "authorization" do
  context "when user is not a sale" do
    let(:non_sale_user) { create(:user) }
    
    before { sign_in non_sale_user }
    
    it "redirects to root with alert" do
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end
  
  context "when user is super_admin" do
    let(:admin_role) { Role.find_by(name: "Super Admin") || create(:role, name: "Super Admin") }
    let(:admin_user) { create(:user, roles: [admin_role]) }
    
    before { sign_in admin_user }
    
    it "allows access" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
```

---

#### Phase 5: Helper Tests
**File:** `spec/helpers/roles_helper_spec.rb`
```ruby
RSpec.describe RolesHelper, type: :helper do
  describe "#role_icon_bg_class" do
    it "returns red for admin dashboard_type" do
      role = build(:role, dashboard_type: :admin)
      expect(helper.role_icon_bg_class(role)).to include("bg-red")
    end
    
    it "returns green for sale dashboard_type" do
      role = build(:role, dashboard_type: :sale)
      expect(helper.role_icon_bg_class(role)).to include("bg-green")
    end
    
    it "returns purple for call_center dashboard_type" do
      role = build(:role, dashboard_type: :call_center)
      expect(helper.role_icon_bg_class(role)).to include("bg-purple")
    end
    
    it "returns teal for cskh dashboard_type" do
      role = build(:role, dashboard_type: :cskh)
      expect(helper.role_icon_bg_class(role)).to include("bg-teal")
    end
    
    it "returns gray for unknown dashboard_type" do
      role = build(:role, dashboard_type: nil)
      expect(helper.role_icon_bg_class(role)).to include("bg-gray")
    end
  end
  
  describe "#role_icon_class" do
    it "returns shield-check for admin" do
      role = build(:role, dashboard_type: :admin)
      expect(helper.role_icon_class(role)).to include("shield-check")
    end
    
    it "returns currency for sale" do
      role = build(:role, dashboard_type: :sale)
      expect(helper.role_icon_class(role)).to include("currency")
    end
  end
end
```

---

#### Phase 6: Ability Error Handling Tests
**File:** `spec/models/ability_spec.rb` (thêm vào)
```ruby
describe "error handling" do
  let(:user) { create(:user) }
  let(:test_role) { create(:role) }
  
  context "with invalid permission code format" do
    before do
      # Create permission with invalid code (missing dot)
      Permission.create!(code: "invalid_no_dot", name: "Bad Perm")
      test_role.permissions << Permission.find_by(code: "invalid_no_dot")
      user.roles << test_role
    end
    
    it "does not raise error" do
      expect { described_class.new(user) }.not_to raise_error
    end
    
    it "ignores invalid permission" do
      ability = described_class.new(user)
      expect(ability.can?(:invalid_no_dot, :anything)).to be false
    end
  end
  
  context "with empty permission code" do
    before do
      Permission.create!(code: "", name: "Empty Perm")
      test_role.permissions << Permission.find_by(code: "")
      user.roles << test_role
    end
    
    it "does not raise error" do
      expect { described_class.new(user) }.not_to raise_error
    end
  end
  
  context "with nil permission code" do
    it "handles gracefully" do
      # This tests the parse_permission_code method
      ability = described_class.new(user)
      # Internal method, so we test indirectly via not raising
      expect(ability).to be_present
    end
  end
end
```

---

## 5. Rollback Plan

Nếu có vấn đề sau khi deploy:
1. Revert commit về phiên bản trước
2. Chạy lại seeds nếu cần: `docker compose exec app rails db:seed`

---

## 6. Implementation Order

| Phase | Description | Estimated |
|-------|-------------|-----------|
| 1 | Role Constants | 15 min |
| 2 | Model Validations | 10 min |
| 3 | Services Refactoring | 15 min |
| 4 | Controller Authorization | 20 min |
| 5 | Helper Refactoring | 10 min |
| 6 | Ability Error Handling | 10 min |
| 7 | RSpec Tests | 45 min |
| **Total** | | **~2 hours** |

---

## 7. Dependencies

- Không có database migration mới
- Không thay đổi schema
- Tương thích ngược 100% (chỉ refactor internal code)

---

## 8. Checklist Trước Khi Bắt Đầu

- [ ] User đã review và approve plan này
- [ ] Backup database (nếu cần)
- [ ] Chạy `rspec` để xác nhận tests hiện tại pass

---

## 9. Post-Implementation Checklist

- [ ] Tất cả RSpec tests pass
- [ ] Rubocop không có violations
- [ ] Manual testing scenarios pass
- [ ] Code đã được commit với message rõ ràng
