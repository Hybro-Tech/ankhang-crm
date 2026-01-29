# frozen_string_literal: true

# Helper methods for Roles views
module RolesHelper
  # Get icon background color class based on role code
  def role_icon_bg_class(role)
    case role.code
    when "super_admin"
      "bg-red-100 text-red-600"
    when "sale"
      "bg-green-100 text-green-600"
    when "call_center"
      "bg-purple-100 text-purple-600"
    when "cskh"
      "bg-teal-100 text-teal-600"
    else
      # Fallback: match by name for custom roles
      case role.name.to_s.downcase
      when /manager|trưởng/
        "bg-blue-100 text-blue-600"
      else
        "bg-gray-100 text-gray-600"
      end
    end
  end

  # Get icon class based on role code
  def role_icon_class(role)
    case role.code
    when "super_admin"
      "fa-solid fa-shield-halved"
    when "sale"
      "fa-solid fa-headset"
    when "call_center"
      "fa-solid fa-phone"
    when "cskh"
      "fa-solid fa-heart"
    else
      # Fallback: match by name for custom roles
      case role.name.to_s.downcase
      when /manager|trưởng/
        "fa-solid fa-user-tie"
      else
        "fa-solid fa-user"
      end
    end
  end

  # Get category icon for permission matrix
  def category_icon_class(category)
    icons = {
      "Khách hàng" => "fa-solid fa-users text-[#0B387A]",
      "Nhân viên" => "fa-solid fa-id-card text-red-600",
      "Đội nhóm" => "fa-solid fa-user-group text-indigo-600",
      "Phân quyền" => "fa-solid fa-user-shield text-orange-600",
      "Loại dịch vụ" => "fa-solid fa-briefcase text-green-600",
      "Ngày nghỉ" => "fa-solid fa-calendar-xmark text-pink-600"
    }
    icons[category] || "fa-solid fa-folder text-gray-400"
  end

  # Translate category name to Vietnamese (already in Vietnamese, just return)
  def category_name_vi(category)
    category
  end

  # Find specific permission for a category and action type
  # Action types: :view, :create, :edit, :delete, :pick
  def find_permission_for(category, action_type, permissions)
    perms = permissions[category] || []

    suffixes = case action_type
               when :view
                 %w[.view .view_own .view_all .receive]
               when :create
                 %w[.create .send .export]
               when :edit
                 %w[.edit .update .update_status .manage .manage_roles .manage_rules .override]
               when :delete
                 %w[.delete]
               when :pick
                 %w[.pick]
               else
                 []
               end

    perms.find { |p| suffixes.any? { |s| p.code.end_with?(s) } }
  end
end
