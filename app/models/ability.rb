# frozen_string_literal: true

# TASK-015: CanCanCan Ability class with dynamic RBAC
# Loads permissions from database (roles + user overrides)
# TASK-RBAC: Refactored to use concerns for cleaner code
class Ability
  include CanCan::Ability
  include PermissionMapping
  include DataAccessRules

  def initialize(user)
    # TASK-RBAC: Define aliases FIRST (before loading permissions)
    alias_action :view, to: :read
    alias_action :edit, :pick, to: :update
    alias_action :create, :read, :update, :destroy, to: :crud

    # Guest users have no permissions
    return unless user

    # Super Admin = All permissions
    if user.super_admin?
      can :manage, :all
      return
    end

    # Load permissions from roles
    load_role_permissions(user)

    # Apply user-level overrides (grant/deny)
    apply_user_overrides(user)

    # TASK-RBAC: Define data-level access rules
    define_contact_access(user)

    # TASK-RBAC: Define feature access rules
    define_feature_access(user)
  end

  private

  def load_role_permissions(user)
    user.roles.eager_load(:permissions).find_each do |role|
      role.permissions.each { |perm| apply_permission(perm) }
    end
  end

  def apply_user_overrides(user)
    user.user_permissions.eager_load(:permission).find_each do |user_perm|
      if user_perm.granted?
        apply_permission(user_perm.permission)
      else
        revoke_permission(user_perm.permission)
      end
    end
  end

  def apply_permission(perm)
    parsed = parse_permission_code(perm.code)
    return unless parsed

    subject, action = parsed
    rails_action = map_action(action)

    can rails_action, subject

    # Also authorize the corresponding model class
    model_class = subject_to_model_class(subject)
    can rails_action, model_class if model_class
  end

  def revoke_permission(perm)
    parsed = parse_permission_code(perm.code)
    return unless parsed

    subject, action = parsed
    rails_action = map_action(action)

    cannot rails_action, subject

    model_class = subject_to_model_class(subject)
    cannot rails_action, model_class if model_class
  end
end
