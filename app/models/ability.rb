# frozen_string_literal: true

# TASK-015: CanCanCan Ability class with dynamic RBAC
# Loads permissions from database (roles + user overrides)
class Ability
  include CanCan::Ability

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

    # Map custom permission actions to standard Rails/CanCan actions
    rails_action = map_action(action)

    can rails_action, subject

    # Also authorize the corresponding model class for load_and_authorize_resource
    model_class = subject_to_model_class(subject)
    return unless model_class

    can rails_action, model_class
  end

  def revoke_permission(perm)
    parsed = parse_permission_code(perm.code)
    return unless parsed

    subject, action = parsed
    rails_action = map_action(action)

    cannot rails_action, subject

    # Also revoke for model class
    model_class = subject_to_model_class(subject)
    cannot rails_action, model_class if model_class
  end

  # Map DB permission actions to CanCan standard actions
  def map_action(action)
    case action
    when :view then :read
    when :edit then :update
    else action
    end
  end

  # Parse permission code "contacts.view" -> [:contacts, :view]
  # Parse "contacts.update_status" -> [:contacts, :update_status]
  # Returns nil if format is invalid (missing dot separator)
  def parse_permission_code(code)
    return nil if code.blank?

    parts = code.to_s.split(".", 2)
    return nil unless parts.size == 2
    return nil if parts.any?(&:blank?)

    subject = parts[0].to_sym
    action = parts[1].to_sym
    [subject, action]
  end

  # Map permission subject to ActiveRecord model class
  # Returns nil if no matching model exists
  SUBJECT_TO_MODEL = {
    contacts: "Contact",
    roles: "Role",
    employees: "User",
    users: "User",
    teams: "Team",
    permissions: "Permission",
    notifications: "Notification",
    logs: "ActivityLog",
    reports: "Report",
    settings: "Setting",
    deals: "Deal",
    products: "Product",
    coupons: "Coupon",
    holidays: "Holiday",
    service_types: "ServiceType",
    sources: "Source",
    saturday_schedules: "SaturdaySchedule",
    interactions: "Interaction",
    reassign_requests: "ReassignRequest",
    regions: "Region", # TASK-REGION: Region management
    dashboards: nil,
    sales_workspace: nil, # TASK-RBAC: Feature permission
    solid_queue: nil,
    solid_cache: nil,
    solid_cable: nil
  }.freeze

  def subject_to_model_class(subject)
    class_name = SUBJECT_TO_MODEL[subject]
    return nil unless class_name

    class_name.constantize
  rescue NameError
    nil
  end

  # TASK-RBAC: Define data-level access rules for Contacts
  # Uses CanCanCan conditions to enable accessible_by filtering
  def define_contact_access(user)
    # contacts.view_all = See all contacts
    if user.has_permission?("contacts.view_all")
      can :read, Contact
      return
    end

    # contacts.view_team = See contacts in user's teams
    can :read, Contact, team_id: user.team_ids if user.has_permission?("contacts.view_team")

    # contacts.view_own = See only assigned or created contacts
    return unless user.has_permission?("contacts.view_own")

    can :read, Contact, assigned_user_id: user.id
    can :read, Contact, created_by_id: user.id
  end

  # TASK-RBAC: Define feature access rules
  def define_feature_access(user)
    # Sales Workspace access
    can :access, :sales_workspace if user.has_permission?("sales_workspace.access")

    # Reassign request approval (permission OR team leader)
    can :approve, ReassignRequest if user.has_permission?("reassign_requests.approve") || user.team_leader?
  end
end
