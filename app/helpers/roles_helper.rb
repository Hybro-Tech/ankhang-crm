# frozen_string_literal: true

# Helper methods for Roles views
module RolesHelper
  # Get icon background color class based on role name
  def role_icon_bg_class(role)
    case role.name.downcase
    when /admin|super/
      "bg-red-100 text-red-600"
    when /sale|kinh doanh/
      "bg-green-100 text-green-600"
    when /tổng đài|call/
      "bg-purple-100 text-purple-600"
    when /cskh|support/
      "bg-teal-100 text-teal-600"
    when /manager|trưởng/
      "bg-blue-100 text-blue-600"
    else
      "bg-gray-100 text-gray-600"
    end
  end

  # Get icon class based on role name
  def role_icon_class(role)
    case role.name.downcase
    when /admin|super/
      "fa-solid fa-shield-halved"
    when /sale|kinh doanh/
      "fa-solid fa-headset"
    when /tổng đài|call/
      "fa-solid fa-phone"
    when /cskh|support/
      "fa-solid fa-heart"
    when /manager|trưởng/
      "fa-solid fa-user-tie"
    else
      "fa-solid fa-user"
    end
  end

  # Get category icon for permission matrix
  def category_icon_class(category)
    icons = {
      "Contacts" => "fa-solid fa-users text-[#0B387A]",
      "Teams" => "fa-solid fa-user-group text-indigo-600",
      "Users" => "fa-solid fa-id-card text-red-600",
      "Roles" => "fa-solid fa-user-shield text-orange-600",
      "Reports" => "fa-solid fa-chart-pie text-gray-600",
      "Logs" => "fa-solid fa-list-check text-gray-500"
    }
    icons[category] || "fa-solid fa-folder text-gray-400"
  end

  # Translate category name to Vietnamese
  def category_name_vi(category)
    translations = {
      "Contacts" => "Khách hàng",
      "Teams" => "Đội nhóm",
      "Users" => "Nhân viên",
      "Roles" => "Phân quyền",
      "Reports" => "Báo cáo",
      "Logs" => "Nhật ký"
    }
    translations[category] || category
  end
end
