# frozen_string_literal: true

# TASK-RBAC: User authorization methods with caching
# Extracted to reduce User model class length
module UserAuthorization
  extend ActiveSupport::Concern

  PERMISSION_CACHE_TTL = 5.minutes

  # Check if user has role by name
  def role?(role_name)
    roles.exists?(name: role_name)
  end
  alias has_role? role?

  # Check if user has role by code (preferred for system checks)
  def role_code?(role_code)
    roles.exists?(code: role_code)
  end
  alias has_role_code? role_code?

  # Check if user is Super Admin
  def super_admin?
    role_code?(Role::SUPER_ADMIN)
  end

  # Get all effective permission codes (roles + overrides)
  # TASK-RBAC: Now with caching support
  def effective_permission_codes
    return Permission.pluck(:code) if super_admin?

    Rails.cache.fetch(permission_cache_key, expires_in: PERMISSION_CACHE_TTL) do
      compute_effective_permissions
    end
  end

  # Check specific permission by code
  def can_access?(permission_code)
    effective_permission_codes.include?(permission_code)
  end
  alias has_permission? can_access?

  # Get primary dashboard type from user's first role
  def primary_dashboard_type
    roles.order(:id).first&.dashboard_type || "admin"
  end

  # Role-based checks (enum-based for stability)
  def call_center_staff?
    roles.exists?(dashboard_type: :call_center)
  end

  def sale_staff?
    roles.exists?(dashboard_type: :sale)
  end

  def cskh_staff?
    roles.exists?(dashboard_type: :cskh)
  end

  def admin?
    primary_dashboard_type == "admin"
  end

  def team_leader?
    managed_team.present?
  end

  # Invalidate permission cache (called after role/permission changes)
  def invalidate_permission_cache
    Rails.cache.delete(permission_cache_key)
  end

  private

  def permission_cache_key
    "user/#{id}/permissions/v1"
  end

  def compute_effective_permissions
    # Get permissions from roles
    role_codes = roles.eager_load(:permissions).flat_map { |r| r.permissions.pluck(:code) }

    # Apply user-level overrides
    granted_codes = user_permissions.where(granted: true)
                                    .joins(:permission)
                                    .pluck("permissions.code")
    denied_codes = user_permissions.where(granted: false)
                                   .joins(:permission)
                                   .pluck("permissions.code")

    ((role_codes + granted_codes) - denied_codes).uniq
  end
end
