# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    description { 'Test role description' }
    is_system { false }

    trait :system do
      is_system { true }
    end

    trait :super_admin do
      name { 'Super Admin' }
      is_system { true }
      description { 'Quản trị viên hệ thống' }
      initialize_with { Role.find_or_create_by!(name: 'Super Admin') }
    end

    trait :tong_dai do
      name { 'Tổng Đài' }
      description { 'Nhân viên trực tổng đài' }
      initialize_with { Role.find_or_create_by!(name: 'Tổng Đài') }
    end

    trait :sale do
      name { 'Sale' }
      description { 'Nhân viên kinh doanh' }
      initialize_with { Role.find_or_create_by!(name: 'Sale') }
    end

    trait :cskh do
      name { 'CSKH' }
      description { 'Chăm sóc khách hàng' }
      initialize_with { Role.find_or_create_by!(name: 'CSKH') }
    end
  end
end
