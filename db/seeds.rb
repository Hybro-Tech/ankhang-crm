# frozen_string_literal: true

puts "🌱 Seeding RBAC data..."

# 1. Clean up
UserPermission.delete_all
RolePermission.delete_all
Permission.delete_all
Role.delete_all

# 2. Define Permissions (Phase 1 Only)
# NOTE: See docs/planning/phase2_notes.md for Phase 2 permissions (Deals, Products, Coupons)
permissions_data = [
  # Contacts
  { code: "contacts.view", name: "Xem Contact", category: "Contacts",
    description: "Xem danh sách và chi tiết contact" },
  { code: "contacts.create", name: "Tạo Contact", category: "Contacts", description: "Tạo contact mới" },
  { code: "contacts.pick", name: "Pick Contact", category: "Contacts", description: "Nhận contact từ kho" },
  { code: "contacts.edit", name: "Sửa Contact", category: "Contacts", description: "Chỉnh sửa thông tin contact" },
  { code: "contacts.update_status", name: "Cập nhật Status", category: "Contacts",
    description: "Cập nhật trạng thái contact" },
  { code: "contacts.view_failed", name: "Xem Contact Failed", category: "Contacts",
    description: "Xem contact thất bại (cho CSKH)" },

  # Teams
  { code: "teams.view", name: "Xem Team", category: "Teams", description: "Xem danh sách team" },
  { code: "teams.manage", name: "Quản lý Team", category: "Teams", description: "Quản lý team (tạo/sửa/xóa)" },

  # Employees (User model)
  { code: "employees.view", name: "Xem Nhân viên", category: "Employees", description: "Xem danh sách nhân viên" },
  { code: "employees.create", name: "Tạo Nhân viên", category: "Employees", description: "Tạo nhân viên" },
  { code: "employees.edit", name: "Sửa Nhân viên", category: "Employees", description: "Sửa nhân viên" },
  { code: "employees.delete", name: "Xóa Nhân viên", category: "Employees", description: "Xóa nhân viên" },
  { code: "employees.manage_roles", name: "Quản lý Roles", category: "Employees",
    description: "Quản lý vai trò nhân viên" },

  # Roles & Permissions
  { code: "roles.view", name: "Xem Role", category: "Roles", description: "Xem danh sách vai trò" },
  { code: "roles.manage", name: "Quản lý Role", category: "Roles", description: "Quản lý vai trò" },
  { code: "permissions.override", name: "Override Permission", category: "Roles", description: "Gán quyền riêng lẻ" },

  # Notifications
  { code: "notifications.view", name: "Xem Thông báo", category: "Notifications", description: "Xem thông báo" },
  { code: "notifications.receive", name: "Nhận Thông báo", category: "Notifications", description: "Nhận thông báo" },
  { code: "notifications.send", name: "Gửi Thông báo", category: "Notifications", description: "Gửi thông báo" },
  { code: "notifications.manage_rules", name: "Quản lý Luật", category: "Notifications",
    description: "Quản lý luật thông báo" },

  # Zalo OA
  { code: "zalo.send", name: "Gửi Zalo", category: "Zalo", description: "Gửi tin nhắn Zalo" },

  # Logs
  { code: "logs.view_own", name: "Xem Log cá nhân", category: "Logs", description: "Xem log cá nhân" },
  { code: "logs.view_all", name: "Xem tất cả Log", category: "Logs", description: "Xem tất cả log" },

  # Reports & Settings
  { code: "reports.view", name: "Xem Báo cáo", category: "Reports", description: "Xem báo cáo" },
  { code: "reports.export", name: "Xuất Báo cáo", category: "Reports", description: "Xuất báo cáo" },
  { code: "settings.view", name: "Xem Cài đặt", category: "Settings", description: "Xem cài đặt" },
  { code: "settings.manage", name: "Quản lý Cài đặt", category: "Settings", description: "Quản lý cài đặt" }
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
  { name: "Super Admin", description: "Quản trị viên hệ thống", is_system: true },
  { name: "Tổng Đài", description: "Nhân viên trực tổng đài", is_system: false },
  { name: "Sale", description: "Nhân viên kinh doanh", is_system: false },
  { name: "CSKH", description: "Chăm sóc khách hàng", is_system: false }
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
roles["Super Admin"].permissions = Permission.all

# Tổng Đài
td_codes = %w[contacts.view contacts.create notifications.receive]
roles["Tổng Đài"].permissions = Permission.where(code: td_codes)

# Sale (Phase 1: No deals - see Phase 2 notes)
sale_codes = %w[
  contacts.view contacts.pick contacts.edit contacts.update_status
  notifications.receive logs.view_own
]
roles["Sale"].permissions = Permission.where(code: sale_codes)

# CSKH
cskh_codes = %w[
  contacts.view_failed contacts.edit contacts.update_status
  zalo.send notifications.receive logs.view_own
]
roles["CSKH"].permissions = Permission.where(code: cskh_codes)

# 5. Create Teams (TASK-009)
puts "➡️ Creating Teams..."
teams_data = [
  { name: "Team Hà Nội", description: "Đội ngũ kinh doanh khu vực Miền Bắc", region: "Bắc" },
  { name: "Team HCM", description: "Đội ngũ kinh doanh khu vực Miền Nam", region: "Nam" },
  { name: "Team Kế toán", description: "Đội ngũ xử lý dịch vụ Kế toán", region: "Trung" }
]

teams_data.each do |t|
  Team.find_or_create_by!(name: t[:name]) do |team|
    team.description = t[:description]
    team.region = t[:region]
  end
end

# 6. Create Test Users (TASK-015)
puts "➡️ Creating Test Users..."

# Clean up existing test users first
User.where("email LIKE '%@ankhang.test'").destroy_all

teams = Team.all.index_by(&:name)

test_users = [
  # Super Admin
  {
    email: "admin@ankhang.test",
    username: "admin",
    name: "Nguyễn Văn Admin",
    password: "Admin@123",
    role: "Super Admin",
    team: nil
  },
  # Tổng Đài
  {
    email: "tongdai1@ankhang.test",
    username: "tongdai1",
    name: "Trần Thị Tổng Đài",
    password: "Tongdai@123",
    role: "Tổng Đài",
    team: nil
  },
  {
    email: "tongdai2@ankhang.test",
    username: "tongdai2",
    name: "Lê Văn Tiếp Nhận",
    password: "Tongdai@123",
    role: "Tổng Đài",
    team: nil
  },
  # Sale - Team Hà Nội
  {
    email: "sale.hn1@ankhang.test",
    username: "sale_hn1",
    name: "Phạm Văn Sale HN",
    password: "Sale@123",
    role: "Sale",
    team: "Team Hà Nội"
  },
  {
    email: "sale.hn2@ankhang.test",
    username: "sale_hn2",
    name: "Hoàng Thị Kinh Doanh",
    password: "Sale@123",
    role: "Sale",
    team: "Team Hà Nội"
  },
  # Sale - Team HCM
  {
    email: "sale.hcm1@ankhang.test",
    username: "sale_hcm1",
    name: "Võ Văn Sale HCM",
    password: "Sale@123",
    role: "Sale",
    team: "Team HCM"
  },
  {
    email: "sale.hcm2@ankhang.test",
    username: "sale_hcm2",
    name: "Đặng Thị Bán Hàng",
    password: "Sale@123",
    role: "Sale",
    team: "Team HCM"
  },
  # CSKH
  {
    email: "cskh1@ankhang.test",
    username: "cskh1",
    name: "Bùi Văn Chăm Sóc",
    password: "Cskh@123",
    role: "CSKH",
    team: nil
  },
  {
    email: "cskh2@ankhang.test",
    username: "cskh2",
    name: "Ngô Thị Hỗ Trợ",
    password: "Cskh@123",
    role: "CSKH",
    team: nil
  }
]

test_users.each do |u|
  user = User.find_or_create_by!(email: u[:email]) do |new_user|
    new_user.username = u[:username]
    new_user.name = u[:name]
    new_user.password = u[:password]
    new_user.password_confirmation = u[:password]
    new_user.team = teams[u[:team]] if u[:team]
  end

  # Assign role
  role = roles[u[:role]]
  user.roles << role unless user.roles.include?(role)

  puts "   ✓ #{u[:email]} (#{u[:role]})"
end

puts "✅ Seed completed!"
puts ""
puts "📧 Test Accounts:"
puts "   admin@ankhang.test / Admin@123 (Super Admin)"
puts "   tongdai1@ankhang.test / Tongdai@123 (Tổng Đài)"
puts "   sale.hn1@ankhang.test / Sale@123 (Sale - Team Hà Nội)"
puts "   sale.hcm1@ankhang.test / Sale@123 (Sale - Team HCM)"
puts "   cskh1@ankhang.test / Cskh@123 (CSKH)"
