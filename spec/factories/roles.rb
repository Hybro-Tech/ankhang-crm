# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    description { "Test role description" }
    is_system { false }

    trait :system do
      is_system { true }
    end

    trait :super_admin do
      name { "Super Admin" }
      code { RoleCodes::SUPER_ADMIN }
      is_system { true }
      dashboard_type { :admin }
      description { "Quản trị viên hệ thống" }
      initialize_with { Role.find_or_create_by!(name: "Super Admin") { |r| r.code = RoleCodes::SUPER_ADMIN; r.dashboard_type = :admin; r.is_system = true } }
    end

    trait :tong_dai do
      name { "Tổng Đài" }
      code { RoleCodes::CALL_CENTER }
      is_system { true }
      dashboard_type { :call_center }
      description { "Nhân viên trực tổng đài" }
      initialize_with { Role.find_or_create_by!(name: "Tổng Đài") { |r| r.code = RoleCodes::CALL_CENTER; r.dashboard_type = :call_center; r.is_system = true } }
    end

    trait :sale do
      name { "Sale" }
      code { RoleCodes::SALE }
      is_system { true }
      dashboard_type { :sale }
      description { "Nhân viên kinh doanh" }
      initialize_with { Role.find_or_create_by!(name: "Sale") { |r| r.code = RoleCodes::SALE; r.dashboard_type = :sale; r.is_system = true } }
    end

    trait :cskh do
      name { "CSKH" }
      code { RoleCodes::CSKH }
      is_system { true }
      dashboard_type { :cskh }
      description { "Chăm sóc khách hàng" }
      initialize_with { Role.find_or_create_by!(name: "CSKH") { |r| r.code = RoleCodes::CSKH; r.dashboard_type = :cskh; r.is_system = true } }
    end
  end
end
