# frozen_string_literal: true

# TASK-015: Authorization helpers for views
module AuthorizationHelper
  # Check if current user has permission by code string
  # Example: can_access?('contacts.view')
  def can_access?(permission_code)
    return false unless current_user

    current_user.can_access?(permission_code)
  end

  # Sidebar menu visibility helper
  # Returns true if user is logged in AND (no permission required OR user has permission)
  def show_menu_item?(permission_code = nil)
    return false unless current_user

    # If no specific permission required, logged-in user can see
    return true if permission_code.blank?

    can_access?(permission_code)
  end

  # Check if user has specific role
  def has_role?(role_name)
    return false unless current_user

    current_user.has_role?(role_name)
  end

  # Check if user is Super Admin
  def super_admin?
    return false unless current_user

    current_user.super_admin?
  end
end
