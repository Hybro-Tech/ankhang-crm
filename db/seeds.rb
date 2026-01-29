# frozen_string_literal: true

Rails.logger.debug "🌱 Seeding RBAC data..."

# 1. Clean up old permissions (safe to run - cleans up deprecated permissions)
Rails.logger.debug "🗑️ Cleaning up old permission data..."
RolePermission.delete_all
UserPermission.delete_all
Permission.delete_all

# 2. Define Permissions - SIMPLIFIED CRUD-ONLY (6 modules × 4 actions = 24 permissions)
# Special permissions can be added later as needed
permissions_data = [
  # Khách hàng (Contacts)
  { code: "contacts.view", name: "Xem", category: "Khách hàng", description: "Xem danh sách và chi tiết khách hàng" },
  { code: "contacts.create", name: "Tạo", category: "Khách hàng", description: "Tạo khách hàng mới" },
  { code: "contacts.edit", name: "Sửa", category: "Khách hàng", description: "Chỉnh sửa thông tin khách hàng" },
  { code: "contacts.delete", name: "Xóa", category: "Khách hàng", description: "Xóa khách hàng" },

  # Nhân viên (Employees/Users)
  { code: "employees.view", name: "Xem", category: "Nhân viên", description: "Xem danh sách nhân viên" },
  { code: "employees.create", name: "Tạo", category: "Nhân viên", description: "Tạo nhân viên mới" },
  { code: "employees.edit", name: "Sửa", category: "Nhân viên", description: "Chỉnh sửa thông tin nhân viên" },
  { code: "employees.delete", name: "Xóa", category: "Nhân viên", description: "Xóa nhân viên" },

  # Đội nhóm (Teams)
  { code: "teams.view", name: "Xem", category: "Đội nhóm", description: "Xem danh sách đội nhóm" },
  { code: "teams.create", name: "Tạo", category: "Đội nhóm", description: "Tạo đội nhóm mới" },
  { code: "teams.edit", name: "Sửa", category: "Đội nhóm", description: "Chỉnh sửa đội nhóm" },
  { code: "teams.delete", name: "Xóa", category: "Đội nhóm", description: "Xóa đội nhóm" },

  # Phân quyền (Roles)
  { code: "roles.view", name: "Xem", category: "Phân quyền", description: "Xem danh sách vai trò" },
  { code: "roles.create", name: "Tạo", category: "Phân quyền", description: "Tạo vai trò mới" },
  { code: "roles.edit", name: "Sửa", category: "Phân quyền", description: "Chỉnh sửa vai trò" },
  { code: "roles.delete", name: "Xóa", category: "Phân quyền", description: "Xóa vai trò" },

  # Loại dịch vụ (Service Types)
  { code: "service_types.view", name: "Xem", category: "Loại dịch vụ", description: "Xem danh sách loại dịch vụ" },
  { code: "service_types.create", name: "Tạo", category: "Loại dịch vụ", description: "Tạo loại dịch vụ mới" },
  { code: "service_types.edit", name: "Sửa", category: "Loại dịch vụ", description: "Chỉnh sửa loại dịch vụ" },
  { code: "service_types.delete", name: "Xóa", category: "Loại dịch vụ", description: "Xóa loại dịch vụ" },

  # Nguồn khách hàng (Sources)
  { code: "sources.view", name: "Xem", category: "Nguồn khách hàng", description: "Xem danh sách nguồn khách hàng" },
  { code: "sources.create", name: "Tạo", category: "Nguồn khách hàng", description: "Tạo nguồn khách hàng mới" },
  { code: "sources.edit", name: "Sửa", category: "Nguồn khách hàng", description: "Chỉnh sửa nguồn khách hàng" },
  { code: "sources.delete", name: "Xóa", category: "Nguồn khách hàng", description: "Xóa nguồn khách hàng" },

  # Ngày nghỉ (Holidays)
  { code: "holidays.view", name: "Xem", category: "Ngày nghỉ", description: "Xem lịch nghỉ lễ" },
  { code: "holidays.create", name: "Tạo", category: "Ngày nghỉ", description: "Thêm ngày nghỉ mới" },
  { code: "holidays.edit", name: "Sửa", category: "Ngày nghỉ", description: "Chỉnh sửa ngày nghỉ" },
  { code: "holidays.delete", name: "Xóa", category: "Ngày nghỉ", description: "Xóa ngày nghỉ" },
  { code: "holidays.manage", name: "Quản lý", category: "Ngày nghỉ", description: "Quản lý toàn bộ lịch nghỉ" },

  # Lịch thứ 7 (Saturday Schedules)
  { code: "saturday_schedules.view", name: "Xem", category: "Lịch Thứ 7", description: "Xem lịch làm việc thứ 7" },
  { code: "saturday_schedules.create", name: "Tạo", category: "Lịch Thứ 7", description: "Tạo lịch làm việc thứ 7" },
  { code: "saturday_schedules.edit", name: "Sửa", category: "Lịch Thứ 7", description: "Chỉnh sửa lịch thứ 7" },
  { code: "saturday_schedules.delete", name: "Xóa", category: "Lịch Thứ 7", description: "Xóa lịch thứ 7" },
  { code: "saturday_schedules.manage", name: "Quản lý", category: "Lịch Thứ 7",
    description: "Quản lý toàn bộ lịch thứ 7" },

  # Dashboard (Role-specific views)
  { code: "dashboards.view_call_center", name: "Xem Tổng Đài", category: "Dashboard",
    description: "Xem dashboard Tổng Đài" },
  { code: "dashboards.view_sales", name: "Xem Sale", category: "Dashboard",
    description: "Xem dashboard và workspace Sale" },
  { code: "dashboards.view_cskh", name: "Xem CSKH", category: "Dashboard", description: "Xem dashboard CSKH" },
  { code: "dashboards.view_admin", name: "Xem Admin", category: "Dashboard", description: "Xem dashboard Admin" },

  # Reports & Logs (System)
  { code: "reports.view", name: "Xem", category: "Báo cáo", description: "Xem báo cáo" },
  { code: "reports.export", name: "Xuất", category: "Báo cáo", description: "Xuất báo cáo" },
  { code: "logs.view", name: "Xem", category: "Nhật ký", description: "Xem nhật ký hoạt động" },

  # Cài đặt hệ thống (Settings)
  { code: "settings.manage", name: "Quản lý", category: "Cài đặt", description: "Quản lý cài đặt hệ thống (giờ làm việc, Smart Routing)" }
]

Rails.logger.debug { "➡️ Creating #{permissions_data.size} permissions..." }
permissions_data.each do |p|
  Permission.find_or_create_by!(code: p[:code]) do |perm|
    perm.name = p[:name]
    perm.category = p[:category]
    perm.description = p[:description]
  end
end

# 3. Create Roles with dashboard_type
Rails.logger.debug "➡️ Creating Roles..."
roles_data = [
  { code: "super_admin", name: "Super Admin", description: "Quản trị viên hệ thống", is_system: true, dashboard_type: :admin },
  { code: "call_center", name: "Tổng Đài", description: "Nhân viên trực tổng đài", is_system: true, dashboard_type: :call_center },
  { code: "sale", name: "Sale", description: "Nhân viên kinh doanh", is_system: true, dashboard_type: :sale },
  { code: "cskh", name: "CSKH", description: "Chăm sóc khách hàng", is_system: true, dashboard_type: :cskh }
]

roles = {}
roles_data.each do |r|
  role = Role.find_or_initialize_by(name: r[:name])
  # Ensure we can update system roles during seeding
  role.description = r[:description]
  role.dashboard_type = r[:dashboard_type]
  role.code = r[:code]

  if role.new_record?
    role.is_system = r[:is_system]
    role.save!
  else
    # Bypass before_update callback for system roles
    # rubocop:disable Rails/SkipsModelValidations
    role.update_columns(
      code: r[:code],
      description: r[:description],
      is_system: r[:is_system],
      dashboard_type: Role.dashboard_types[r[:dashboard_type]]
    )
    # rubocop:enable Rails/SkipsModelValidations
  end
  roles[r[:name]] = role
end

# 4. Assign Permissions
Rails.logger.debug "➡️ Assigning Permissions..."

# Super Admin: All permissions (also has can :manage, :all in Ability)
roles["Super Admin"].permissions = Permission.all

# Tổng Đài - Contact CRUD for data entry + Call Center dashboard
td_codes = %w[
  contacts.view contacts.create contacts.edit
  dashboards.view_call_center
]
roles["Tổng Đài"].permissions = Permission.where(code: td_codes)

# Sale - Contact access + Sales dashboard/workspace
sale_codes = %w[
  contacts.view contacts.edit
  dashboards.view_sales
]
roles["Sale"].permissions = Permission.where(code: sale_codes)

# CSKH - Contact access for care + CSKH dashboard
cskh_codes = %w[
  contacts.view contacts.edit
  dashboards.view_cskh
]
roles["CSKH"].permissions = Permission.where(code: cskh_codes)

# 5. Create Teams (TASK-009)
Rails.logger.debug "➡️ Creating Teams..."
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

# 6. Create Service Types (TASK-019 prerequisite)
Rails.logger.debug "➡️ Creating Service Types (Loại nhu cầu)..."
teams_lookup = Team.all.index_by(&:name)

service_types_data = [
  { name: "Thành lập công ty", description: "Dịch vụ thành lập doanh nghiệp", team: "Team Hà Nội", position: 1 },
  { name: "Thay đổi đăng ký kinh doanh", description: "Thay đổi thông tin ĐKKD", team: "Team Hà Nội", position: 2 },
  { name: "Giải thể công ty", description: "Thủ tục giải thể doanh nghiệp", team: "Team Hà Nội", position: 3 },
  { name: "Kế toán thuế", description: "Dịch vụ kế toán - khai thuế", team: "Team Kế toán", position: 4 },
  { name: "Báo cáo tài chính", description: "Lập BCTC hàng năm", team: "Team Kế toán", position: 5 },
  { name: "Sở hữu trí tuệ", description: "Đăng ký nhãn hiệu, bản quyền", team: "Team HCM", position: 6 },
  { name: "Giấy phép con", description: "Xin các loại giấy phép kinh doanh", team: "Team HCM", position: 7 },
  { name: "Tư vấn pháp lý", description: "Tư vấn pháp luật doanh nghiệp", team: "Team HCM", position: 8 },
  { name: "Khác", description: "Nhu cầu khác", team: nil, position: 99 }
]

service_types_data.each do |st|
  ServiceType.find_or_create_by!(name: st[:name]) do |service_type|
    service_type.description = st[:description]
    service_type.team = teams_lookup[st[:team]] if st[:team]
    service_type.position = st[:position]
    service_type.active = true
  end
end

# 7. Create Sources (Dynamic CRUD)
Rails.logger.debug "➡️ Creating Sources (Nguồn khách hàng)..."
sources_data = [
  { name: "Ladi Zalo/Hotline", position: 0 },
  { name: "Facebook", position: 1 },
  { name: "Google", position: 2 },
  { name: "Giới thiệu", position: 3 },
  { name: "Khác", position: 4 }
]

sources_data.each do |s|
  Source.find_or_create_by!(name: s[:name]) do |source|
    source.position = s[:position]
    source.active = true
    source.description = "Nguồn mặc định"
  end
end

# 8. Create Test Users (TASK-015)
Rails.logger.debug "➡️ Creating Test Users..."

# Clean up existing test users first
users_to_delete = User.where("email LIKE '%@ankhang.test'")
# Delete dependent logs to avoid FK error
ActivityLog.where(user_id: users_to_delete.pluck(:id)).delete_all if defined?(ActivityLog)
users_to_delete.destroy_all

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
    new_user.teams << teams[u[:team]] if u[:team]
  end

  # Assign role
  role = roles[u[:role]]
  user.roles << role unless user.roles.include?(role)

  Rails.logger.debug { "   ✓ #{u[:email]} (#{u[:role]})" }
end

# 7. Seed Holidays (TASK-047)
Rails.logger.debug "➡️ Creating Holidays..."
holidays2025 = [
  { date: "2025-01-01", name: "Tết Dương lịch" },
  # Tet Nguyen Dan (Jan 25 - Feb 2)
  { date: "2025-01-25", name: "Nghỉ Tết Âm lịch (26 tháng Chạp)" },
  { date: "2025-01-26", name: "Nghỉ Tết Âm lịch (27 tháng Chạp)" },
  { date: "2025-01-27", name: "Nghỉ Tết Âm lịch (28 tháng Chạp)" },
  { date: "2025-01-28", name: "Nghỉ Tết Âm lịch (29 tháng Chạp)" },
  { date: "2025-01-29", name: "Tết Nguyên Đán (Mùng 1)" },
  { date: "2025-01-30", name: "Tết Nguyên Đán (Mùng 2)" },
  { date: "2025-01-31", name: "Tết Nguyên Đán (Mùng 3)" },
  { date: "2025-02-01", name: "Nghỉ Tết Âm lịch (Mùng 4)" },
  { date: "2025-02-02", name: "Nghỉ Tết Âm lịch (Mùng 5)" },
  # Hung Kings
  { date: "2025-04-07", name: "Giỗ tổ Hùng Vương" },
  # 30/4 - 1/5
  { date: "2025-04-30", name: "Ngày Thống nhất đất nước" },
  { date: "2025-05-01", name: "Quốc tế Lao động" },
  { date: "2025-05-02", name: "Nghỉ lễ 30/4-1/5 (Hoán đổi/Nghỉ bù)" },
  # National Day (Aug 30 - Sep 2)
  { date: "2025-08-30", name: "Nghỉ lễ Quốc khánh" },
  { date: "2025-08-31", name: "Nghỉ lễ Quốc khánh" },
  { date: "2025-09-01", name: "Nghỉ lễ Quốc khánh" },
  { date: "2025-09-02", name: "Quốc khánh" }
]

holidays2025.each do |h|
  Holiday.find_or_create_by!(date: h[:date]) do |holiday|
    holiday.name = h[:name]
    holiday.description = "Lịch nghỉ lễ chính thức năm 2025"
  end
end

Rails.logger.debug "✅ Seed completed!"
Rails.logger.debug ""
Rails.logger.debug "📧 Test Accounts:"
Rails.logger.debug "   admin@ankhang.test / Admin@123 (Super Admin)"
Rails.logger.debug "   tongdai1@ankhang.test / Tongdai@123 (Tổng Đài)"
Rails.logger.debug "   sale.hn1@ankhang.test / Sale@123 (Sale - Team Hà Nội)"
Rails.logger.debug "   sale.hcm1@ankhang.test / Sale@123 (Sale - Team HCM)"
Rails.logger.debug "   cskh1@ankhang.test / Cskh@123 (CSKH)"
