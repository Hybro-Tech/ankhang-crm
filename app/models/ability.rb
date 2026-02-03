# frozen_string_literal: true

# TASK-015: CanCanCan Ability class with dynamic RBAC
# Loads permissions from database (roles + user overrides)
# TASK-RBAC: Refactored to use concerns for cleaner code
# TASK-PERF: Optimized for performance - memoization and batched queries
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

    # TASK-PERF: Store user reference and cache super_admin status
    @user = user
    @is_super_admin = user.super_admin?

    # Super Admin = All permissions
    if @is_super_admin
      can :manage, :all
      return
    end

    # TASK-PERF: Preload associations for better performance
    preload_user_associations

    # Load permissions from roles
    load_role_permissions

    # Apply user-level overrides (grant/deny)
    apply_user_overrides

    # TASK-RBAC: Define data-level access rules
    define_contact_access(@user)

    # TASK-RBAC: Define feature access rules
    define_feature_access(@user)
  end

  private

  # TASK-PERF: Preload all needed associations in one query (if not already loaded)
  def preload_user_associations
    # Skip if already loaded (e.g., from controller eager loading)
    return if @user.roles.loaded? && @user.user_permissions.loaded?

    ActiveRecord::Associations::Preloader.new(
      records: [@user],
      associations: [
        { roles: :permissions },
        { user_permissions: :permission },
        :managed_team
      ]
    ).call
  end

  # TASK-PERF: Use each instead of find_each - better for small datasets
  def load_role_permissions
    @user.roles.each do |role|
      role.permissions.each { |perm| apply_permission(perm) }
    end
  end

  # TASK-PERF: Use each instead of find_each
  def apply_user_overrides
    @user.user_permissions.each do |user_perm|
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
