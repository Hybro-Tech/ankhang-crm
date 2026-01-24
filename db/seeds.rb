# frozen_string_literal: true

puts "🌱 Seeding RBAC data..."

# 1. Clean up
UserPermission.delete_all
RolePermission.delete_all
Permission.delete_all
Role.delete_all

# 2. Define Permissions
permissions_data = [
  # Contacts
  { code: 'contacts.view', name: 'Xem Contact', category: 'Contacts', description: 'Xem danh sách và chi tiết contact' },
  { code: 'contacts.create', name: 'Tạo Contact', category: 'Contacts', description: 'Tạo contact mới' },
  { code: 'contacts.pick', name: 'Pick Contact', category: 'Contacts', description: 'Nhận contact từ kho' },
  { code: 'contacts.edit', name: 'Sửa Contact', category: 'Contacts', description: 'Chỉnh sửa thông tin contact' },
  { code: 'contacts.update_status', name: 'Cập nhật Status', category: 'Contacts', description: 'Cập nhật trạng thái contact' },
  { code: 'contacts.view_failed', name: 'Xem Contact Failed', category: 'Contacts', description: 'Xem contact thất bại (cho CSKH)' },
  
  # Teams
  { code: 'teams.view', name: 'Xem Team', category: 'Teams', description: 'Xem danh sách team' },
  { code: 'teams.manage', name: 'Quản lý Team', category: 'Teams', description: 'Quản lý team (tạo/sửa/xóa)' },

  # Products & Coupons
  { code: 'products.view', name: 'Xem Sản phẩm', category: 'Products', description: 'Xem danh sách sản phẩm' },
  { code: 'products.manage', name: 'Quản lý Sản phẩm', category: 'Products', description: 'Quản lý sản phẩm' },
  { code: 'coupons.view', name: 'Xem Coupon', category: 'Coupons', description: 'Xem danh sách mã giảm giá' },
  { code: 'coupons.manage', name: 'Quản lý Coupon', category: 'Coupons', description: 'Quản lý mã giảm giá' },

  # Deals
  { code: 'deals.view', name: 'Xem Deal', category: 'Deals', description: 'Xem danh sách deal' },
  { code: 'deals.create', name: 'Tạo Deal', category: 'Deals', description: 'Tạo deal' },
  { code: 'deals.edit', name: 'Sửa Deal', category: 'Deals', description: 'Sửa deal' },
  { code: 'deals.update_payment', name: 'Cập nhật Thanh toán', category: 'Deals', description: 'Cập nhật thanh toán' },

  # Employees (User model)
  { code: 'employees.view', name: 'Xem Nhân viên', category: 'Employees', description: 'Xem danh sách nhân viên' },
  { code: 'employees.create', name: 'Tạo Nhân viên', category: 'Employees', description: 'Tạo nhân viên' },
  { code: 'employees.edit', name: 'Sửa Nhân viên', category: 'Employees', description: 'Sửa nhân viên' },
  { code: 'employees.delete', name: 'Xóa Nhân viên', category: 'Employees', description: 'Xóa nhân viên' },
  { code: 'employees.manage_roles', name: 'Quản lý Roles', category: 'Employees', description: 'Quản lý vai trò nhân viên' },

  # Roles & Permissions
  { code: 'roles.view', name: 'Xem Role', category: 'Roles', description: 'Xem danh sách vai trò' },
  { code: 'roles.manage', name: 'Quản lý Role', category: 'Roles', description: 'Quản lý vai trò' },
  { code: 'permissions.override', name: 'Override Permission', category: 'Roles', description: 'Gán quyền riêng lẻ' },

  # Notifications
  { code: 'notifications.view', name: 'Xem Thông báo', category: 'Notifications', description: 'Xem thông báo' },
  { code: 'notifications.receive', name: 'Nhận Thông báo', category: 'Notifications', description: 'Nhận thông báo' },
  { code: 'notifications.send', name: 'Gửi Thông báo', category: 'Notifications', description: 'Gửi thông báo' },
  { code: 'notifications.manage_rules', name: 'Quản lý Luật', category: 'Notifications', description: 'Quản lý luật thông báo' },

  # Zalo OA
  { code: 'zalo.send', name: 'Gửi Zalo', category: 'Zalo', description: 'Gửi tin nhắn Zalo' },

  # Logs
  { code: 'logs.view_own', name: 'Xem Log cá nhân', category: 'Logs', description: 'Xem log cá nhân' },
  { code: 'logs.view_all', name: 'Xem tất cả Log', category: 'Logs', description: 'Xem tất cả log' },

  # Reports & Settings
  { code: 'reports.view', name: 'Xem Báo cáo', category: 'Reports', description: 'Xem báo cáo' },
  { code: 'reports.export', name: 'Xuất Báo cáo', category: 'Reports', description: 'Xuất báo cáo' },
  { code: 'settings.view', name: 'Xem Cài đặt', category: 'Settings', description: 'Xem cài đặt' },
  { code: 'settings.manage', name: 'Quản lý Cài đặt', category: 'Settings', description: 'Quản lý cài đặt' }
]

puts "➡️ Creating #{permissions_data.size} permissions..."
permissions_data.each do |p|
  Permission.find_or_create_by!(code: p[:code]) do |perm|
    perm.name = p[:name]
    perm.category = p[:category]
    perm.description = p[:description]
  end
end

# 3. Create Roles
puts "➡️ Creating Roles..."
roles_data = [
  { name: 'Super Admin', description: 'Quản trị viên hệ thống', is_system: true },
  { name: 'Tổng Đài', description: 'Nhân viên trực tổng đài', is_system: false },
  { name: 'Sale', description: 'Nhân viên kinh doanh', is_system: false },
  { name: 'CSKH', description: 'Chăm sóc khách hàng', is_system: false }
]

roles = {}
roles_data.each do |r|
  roles[r[:name]] = Role.find_or_create_by!(name: r[:name]) do |role|
    role.description = r[:description]
    role.is_system = r[:is_system]
  end
end

# 4. Assign Permissions
puts "➡️ Assigning Permissions..."

# Super Admin: All permissions
roles['Super Admin'].permissions = Permission.all

# Tổng Đài
td_codes = %w[contacts.view contacts.create notifications.receive]
roles['Tổng Đài'].permissions = Permission.where(code: td_codes)

# Sale
sale_codes = %w[
  contacts.view contacts.pick contacts.edit contacts.update_status
  deals.view deals.create deals.edit deals.update_payment
  notifications.receive logs.view_own
]
roles['Sale'].permissions = Permission.where(code: sale_codes)

# CSKH
cskh_codes = %w[
  contacts.view_failed contacts.edit contacts.update_status
  zalo.send notifications.receive logs.view_own
]
roles['CSKH'].permissions = Permission.where(code: cskh_codes)

puts "✅ Seed completed!"
