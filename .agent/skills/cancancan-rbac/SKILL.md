---
name: cancancan-rbac
description: CanCanCan authorization patterns for dynamic RBAC. Role-based permissions, user overrides, permission matrix UI.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# CanCanCan Authorization

> **Dynamic RBAC for Rails.** Roles, Permissions, User Overrides.
> Admin creates roles, assigns permissions via UI.

---

## 🎯 AnKhangCRM Requirements

| ID | Requirement | CanCanCan Solution |
|----|-------------|-------------------|
| PERM-001 | Create/edit/delete Roles | `Role` model + CRUD |
| PERM-002 | Role has Permissions | `role_permissions` join |
| PERM-003 | User has many Roles | `user_roles` join |
| PERM-004 | User permission override | `user_permissions` with `granted` |
| PERM-005 | Permission matrix UI | Load from DB dynamically |
| PERM-006 | Protect system roles | `is_system` flag |
| PERM-007 | Clone role | Copy permissions to new role |

---

## 📊 Database Schema

```ruby
# db/migrate/xxx_create_authorization_tables.rb
class CreateAuthorizationTables < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :is_system, default: false
      t.timestamps
    end

    create_table :permissions do |t|
      t.string :subject, null: false  # e.g., "Contact", "Deal"
      t.string :action, null: false   # e.g., "read", "create", "pick"
      t.string :description
      t.timestamps
    end

    create_table :role_permissions do |t|
      t.references :role, foreign_key: true
      t.references :permission, foreign_key: true
      t.timestamps
    end

    create_table :user_roles do |t|
      t.references :user, foreign_key: true
      t.references :role, foreign_key: true
      t.timestamps
    end

    create_table :user_permissions do |t|
      t.references :user, foreign_key: true
      t.references :permission, foreign_key: true
      t.boolean :granted, default: true  # true = grant, false = deny
      t.timestamps
    end

    add_index :role_permissions, [:role_id, :permission_id], unique: true
    add_index :user_roles, [:user_id, :role_id], unique: true
    add_index :user_permissions, [:user_id, :permission_id], unique: true
  end
end
```

---

## 🏗️ Models

```ruby
# app/models/role.rb
class Role < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true, uniqueness: true

  scope :user_created, -> { where(is_system: false) }

  def clone_to(new_name)
    new_role = Role.create!(name: new_name, description: "Copy of #{name}")
    permissions.each do |perm|
      new_role.permissions << perm
    end
    new_role
  end
end

# app/models/permission.rb
class Permission < ApplicationRecord
  has_many :role_permissions
  has_many :roles, through: :role_permissions

  validates :subject, :action, presence: true
  validates :action, uniqueness: { scope: :subject }

  def key
    "#{action}_#{subject.underscore}"
  end
end

# app/models/user.rb (additions)
class User < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :user_permissions, dependent: :destroy

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end
end
```

---

## 🔐 Ability Class

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Super Admin = All permissions
    if user.has_role?('Super Admin')
      can :manage, :all
      return
    end

    # Load permissions from roles
    user.roles.includes(permissions: []).each do |role|
      role.permissions.each do |perm|
        apply_permission(perm)
      end
    end

    # Apply user-level overrides (grant/deny)
    user.user_permissions.includes(:permission).each do |up|
      if up.granted
        apply_permission(up.permission)
      else
        revoke_permission(up.permission)
      end
    end
  end

  private

  def apply_permission(perm)
    subject = perm.subject.constantize rescue perm.subject.to_sym
    can perm.action.to_sym, subject
  end

  def revoke_permission(perm)
    subject = perm.subject.constantize rescue perm.subject.to_sym
    cannot perm.action.to_sym, subject
  end
end
```

---

## 🎮 Controller Integration

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Bạn không có quyền thực hiện." }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: "Không có quyền" }) }
    end
  end
end

# Usage in controller
class ContactsController < ApplicationController
  load_and_authorize_resource

  def pick
    authorize! :pick, @contact
    # pick logic
  end
end
```

---

## 🎨 Permission Matrix UI

```ruby
# app/controllers/admin/roles_controller.rb
class Admin::RolesController < ApplicationController
  def edit
    @role = Role.find(params[:id])
    @permissions = Permission.all.group_by(&:subject)
  end

  def update
    @role = Role.find(params[:id])

    if @role.is_system?
      redirect_to admin_roles_path, alert: "Không thể sửa role hệ thống"
      return
    end

    @role.permission_ids = params[:role][:permission_ids]
    redirect_to admin_roles_path, notice: "Đã cập nhật quyền"
  end
end
```

```erb
<%# app/views/admin/roles/edit.html.erb %>
<h1>Phân quyền: <%= @role.name %></h1>

<%= form_with model: @role, url: admin_role_path(@role) do |f| %>
  <table class="permission-matrix">
    <thead>
      <tr>
        <th>Module</th>
        <th>Xem</th>
        <th>Tạo</th>
        <th>Sửa</th>
        <th>Xóa</th>
        <th>Pick</th>
      </tr>
    </thead>
    <tbody>
      <% @permissions.each do |subject, perms| %>
        <tr>
          <td><%= subject %></td>
          <% ['read', 'create', 'update', 'destroy', 'pick'].each do |action| %>
            <td>
              <% perm = perms.find { |p| p.action == action } %>
              <% if perm %>
                <%= check_box_tag "role[permission_ids][]", perm.id,
                    @role.permissions.include?(perm) %>
              <% else %>
                -
              <% end %>
            </td>
          <% end %>
        </tr>
      <% end %>
    </tbody>
  </table>

  <%= f.submit "Lưu", class: "btn btn-primary" %>
<% end %>
```

---

## 🔧 Seed Default Permissions

```ruby
# db/seeds/permissions.rb
PERMISSIONS = [
  # Contacts
  { subject: 'Contact', action: 'read', description: 'Xem khách hàng' },
  { subject: 'Contact', action: 'create', description: 'Tạo khách hàng' },
  { subject: 'Contact', action: 'update', description: 'Sửa khách hàng' },
  { subject: 'Contact', action: 'destroy', description: 'Xóa khách hàng' },
  { subject: 'Contact', action: 'pick', description: 'Nhận khách hàng' },

  # Deals
  { subject: 'Deal', action: 'read', description: 'Xem cơ hội' },
  { subject: 'Deal', action: 'create', description: 'Tạo cơ hội' },
  { subject: 'Deal', action: 'update', description: 'Sửa cơ hội' },

  # Reports
  { subject: 'Report', action: 'read', description: 'Xem báo cáo' },

  # Admin
  { subject: 'User', action: 'manage', description: 'Quản lý nhân viên' },
  { subject: 'Role', action: 'manage', description: 'Quản lý phân quyền' },
  { subject: 'Team', action: 'manage', description: 'Quản lý đội nhóm' },
]

PERMISSIONS.each do |attrs|
  Permission.find_or_create_by!(subject: attrs[:subject], action: attrs[:action]) do |p|
    p.description = attrs[:description]
  end
end

# Default Roles
super_admin = Role.find_or_create_by!(name: 'Super Admin', is_system: true)
super_admin.permissions = Permission.all

tong_dai = Role.find_or_create_by!(name: 'Tổng Đài', is_system: true)
tong_dai.permissions = Permission.where(subject: 'Contact', action: ['read', 'create'])

sales = Role.find_or_create_by!(name: 'Sale', is_system: true)
sales.permissions = Permission.where(subject: 'Contact', action: ['read', 'update', 'pick']) +
                   Permission.where(subject: 'Deal')
```

---

## ❌ Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Hardcode permissions in code | Load from database |
| Skip authorization checks | Always use `authorize!` |
| Allow deleting system roles | Check `is_system` flag |
| Complex nested abilities | Keep ability logic simple |

---

## ✅ Checklist

- [ ] Permission table seeded?
- [ ] Default roles created?
- [ ] Ability class loads from DB?
- [ ] User overrides working?
- [ ] Matrix UI functional?
- [ ] System roles protected?
