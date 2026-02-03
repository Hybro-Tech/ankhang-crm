# RBAC Dynamic Permissions - Implementation Plan

> **Version:** 1.0  
> **Created:** 2026-02-03  
> **Status:** PENDING APPROVAL

---

## 1. Mục tiêu

Chuyển đổi hệ thống phân quyền từ **hardcoded role checks** sang **dynamic permission-based** system:

| Hiện tại (Hardcode) | Sau refactor (Dynamic) |
|---------------------|------------------------|
| `current_user.sale_staff?` | `can?(:view_own, Contact)` |
| `current_user.super_admin?` | `can?(:view_all, Contact)` |
| `current_user.team_leader?` | `can?(:approve, ReassignRequest)` |

---

## 2. Proposed Changes

### Phase 1: Data Filtering Permissions (P0)

#### [NEW] Permissions trong `db/seeds.rb`

```ruby
# Thêm vào PERMISSIONS array
{ code: "contacts.view_all", name: "Xem tất cả khách hàng", category: "Khách hàng" },
{ code: "contacts.view_team", name: "Xem KH trong team", category: "Khách hàng" },
{ code: "contacts.view_own", name: "Xem KH của mình", category: "Khách hàng" },
```

#### [MODIFY] `app/models/ability.rb`

**Vị trí:** Sau `load_role_permissions(user)`, thêm:

```ruby
private

def define_contact_access(user)
  if user.has_permission?("contacts.view_all")
    can :read, Contact
  elsif user.has_permission?("contacts.view_team")
    can :read, Contact, team_id: user.team_ids
  elsif user.has_permission?("contacts.view_own")
    can :read, Contact, assigned_user_id: user.id
    can :read, Contact, created_by_id: user.id
  end
end
```

**Gọi method trong initialize:**
```ruby
def initialize(user)
  # ... existing code ...
  load_role_permissions(user)
  apply_user_overrides(user)
  define_contact_access(user)  # 👈 Thêm dòng này
end
```

#### [MODIFY] `app/controllers/contacts_controller.rb`

**Xóa (lines 220-230):**
```ruby
# XÓA đoạn code này:
return query if current_user.super_admin?
query = query.where(created_by_id: current_user.id) if current_user.call_center_staff?
query = query.where(assigned_user_id: current_user.id) if current_user.sale_staff?
```

**Thay bằng:**
```ruby
def base_contacts_query
  Contact.accessible_by(current_ability)
         .includes(:service_type, :team, :assigned_user, :creator)
         .order(created_at: :desc)
end
```

#### [MODIFY] `db/seeds.rb` - Role Permissions Mapping

```ruby
# Super Admin: view_all
# Sale: view_own
# Call Center: view_own (contacts they created)
# CSKH: view_team

ROLE_PERMISSIONS["Super Admin"] << "contacts.view_all"
ROLE_PERMISSIONS["Sale"] << "contacts.view_own"
ROLE_PERMISSIONS["Tổng Đài"] << "contacts.view_own"
ROLE_PERMISSIONS["CSKH"] << "contacts.view_team"
```

---

### Phase 2: Feature Access Permissions (P0)

#### [NEW] Permissions trong `db/seeds.rb`

```ruby
{ code: "sales_workspace.access", name: "Truy cập Sales Workspace", category: "Dashboards" },
{ code: "reassign_requests.approve", name: "Duyệt yêu cầu chuyển giao", category: "Yêu cầu" },
```

#### [MODIFY] `app/models/ability.rb`

```ruby
def define_feature_access(user)
  can :access, :sales_workspace if user.has_permission?("sales_workspace.access")
  can :approve, ReassignRequest if user.has_permission?("reassign_requests.approve") || user.team_leader?
end
```

#### [MODIFY] `app/controllers/sales_workspace_controller.rb`

**Xóa (line 81):**
```ruby
return if current_user.sale_staff? || current_user.super_admin? || current_user.team_leader?
```

**Thay bằng:**
```ruby
def authorize_sale_user
  authorize! :access, :sales_workspace
end
```

---

### Phase 3: View Refactoring (P1)

#### [MODIFY] `app/views/shared/_sidebar.html.erb`

**Line 18 - Thay:**
```erb
<% if current_user.call_center_staff? %>
```
**Bằng:**
```erb
<% if can_access?("dashboards.view_call_center") %>
```

**Line 50 - Thay:**
```erb
<% if current_user.team_leader? %>
```
**Bằng:**
```erb
<% if can_access?("reassign_requests.approve") || current_user.team_leader? %>
```

#### [MODIFY] `app/helpers/authorization_helper.rb`

```ruby
# Thêm helper methods
def can_view_sales_workspace?
  can_access?("sales_workspace.access")
end

def can_approve_reassigns?
  can_access?("reassign_requests.approve") || current_user&.team_leader?
end
```

---

### Phase 4: Alias Actions Order (P2)

#### [MODIFY] `app/models/ability.rb`

**Di chuyển alias_action lên đầu initialize:**

```ruby
def initialize(user)
  # Define aliases FIRST (before loading permissions)
  alias_action :view, to: :read
  alias_action :edit, :pick, to: :update
  alias_action :create, :read, :update, :destroy, to: :crud
  
  return unless user
  
  if user.super_admin?
    can :manage, :all
    return
  end
  
  load_role_permissions(user)
  apply_user_overrides(user)
  define_contact_access(user)
  define_feature_access(user)
end
```

---

### Phase 5: Caching (P2)

#### [MODIFY] `app/models/ability.rb`

```ruby
class Ability
  include CanCan::Ability
  
  def initialize(user)
    return unless user
    
    cached_abilities = Rails.cache.fetch(
      "ability/v1/#{user.id}/#{user.updated_at.to_i}",
      expires_in: 5.minutes
    ) do
      build_abilities_hash(user)
    end
    
    apply_cached_abilities(cached_abilities)
  end
  
  private
  
  def build_abilities_hash(user)
    # Return hash of abilities for caching
  end
  
  def apply_cached_abilities(hash)
    # Apply abilities from cached hash
  end
end
```

#### [MODIFY] `app/models/user_role.rb`

```ruby
after_commit :invalidate_ability_cache

private

def invalidate_ability_cache
  Rails.cache.delete_matched("ability/v1/#{user_id}/*")
end
```

#### [MODIFY] `app/models/role_permission.rb`

```ruby
after_commit :invalidate_role_abilities

private

def invalidate_role_abilities
  role.users.find_each do |user|
    Rails.cache.delete_matched("ability/v1/#{user.id}/*")
  end
end
```

---

## 3. Verification Plan

### Commands

```bash
# 1. Seed new permissions
docker compose exec app rails db:seed

# 2. Run RSpec tests
docker compose exec app bundle exec rspec spec/models/ability_spec.rb
docker compose exec app bundle exec rspec spec/controllers/contacts_controller_spec.rb
docker compose exec app bundle exec rspec spec/controllers/sales_workspace_controller_spec.rb

# 3. Run Rubocop
docker compose exec app bundle exec rubocop -A

# 4. Full test suite
docker compose exec app bundle exec rspec
```

### Manual Testing Scenarios

| Scenario | User | Expected |
|----------|------|----------|
| Sale sees only assigned contacts | sale.hn1@ankhang.test | Chỉ thấy contacts assigned cho mình |
| Call Center sees created contacts | tongdai1@ankhang.test | Chỉ thấy contacts mình tạo |
| Super Admin sees all | admin@ankhang.test | Thấy tất cả contacts |
| Sales Workspace access | sale.hn1@ankhang.test | Có thể access /sales/workspace |
| Non-sale cannot access workspace | cskh1@ankhang.test | Redirect với thông báo lỗi |

---

## 4. Migration Strategy

1. **Prepare:** Thêm permissions mới (không ảnh hưởng existing)
2. **Deploy:** Deploy code changes
3. **Assign:** Gán permissions mới cho roles
4. **Verify:** Test all scenarios
5. **Cleanup:** Remove deprecated checks (optional, sau khi stable)

---

## 5. Rollback Plan

```bash
# Nếu có vấn đề:
git revert HEAD
docker compose exec app rails db:seed  # Re-seed original data
```

---

## 6. Dependencies

- Không có database migration mới (chỉ seed data)
- Không thay đổi schema
- Backward compatible với existing permissions

---

## 7. Checklist trước khi bắt đầu

- [ ] User đã review và approve plan này
- [ ] Docker environment đang chạy
- [ ] Database đã được backup (nếu production)
- [ ] Current tests pass (`rspec` green)

---

## 8. Files tổng hợp sẽ thay đổi

| File | Action | Priority |
|------|--------|----------|
| `db/seeds.rb` | Add permissions | P0 |
| `app/models/ability.rb` | Add methods + reorder | P0 |
| `app/controllers/contacts_controller.rb` | Use accessible_by | P0 |
| `app/controllers/sales_workspace_controller.rb` | Use authorize! | P0 |
| `app/views/shared/_sidebar.html.erb` | Replace role checks | P1 |
| `app/helpers/authorization_helper.rb` | Add helpers | P1 |
| `app/models/user_role.rb` | Cache invalidation | P2 |
| `app/models/role_permission.rb` | Cache invalidation | P2 |
| `spec/models/ability_spec.rb` | Add tests | All |

---

**🎯 Ready for review - Chờ user approve trước khi implement**
