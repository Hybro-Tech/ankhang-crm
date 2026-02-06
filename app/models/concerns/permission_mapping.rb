# frozen_string_literal: true

# TASK-RBAC: Concern for permission code parsing and subject-to-model mapping
# Extracted from Ability class to reduce class length
module PermissionMapping
  extend ActiveSupport::Concern

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
    regions: "Region",
    provinces: "Province", # SECURITY-AUDIT: Added missing mapping
    dashboards: nil,
    sales_workspace: nil,
    solid_queue: nil,
    solid_cache: nil,
    solid_cable: nil
  }.freeze

  private

  # Map DB permission actions to CanCan standard actions
  def map_action(action)
    case action
    when :view then :read
    when :edit then :update
    else action
    end
  end

  # Parse permission code "contacts.view" -> [:contacts, :view]
  def parse_permission_code(code)
    return nil if code.blank?

    parts = code.to_s.split(".", 2)
    return nil unless parts.size == 2
    return nil if parts.any?(&:blank?)

    [parts[0].to_sym, parts[1].to_sym]
  end

  def subject_to_model_class(subject)
    class_name = SUBJECT_TO_MODEL[subject]
    return nil unless class_name

    class_name.constantize
  rescue NameError
    nil
  end
end
