# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    sequence(:code) { |n| "test.permission_#{n}" }
    sequence(:name) { |n| "Test Permission #{n}" }
    category { "Test" }
    description { "Test permission description" }

    # Contacts permissions
    trait :contacts_view do
      code { "contacts.view" }
      name { "Xem Contact" }
      category { "Contacts" }
      initialize_with do
        Permission.find_or_create_by!(code: "contacts.view") do |p|
          p.name = "Xem Contact"
          p.category = "Contacts"
        end
      end
    end

    trait :contacts_create do
      code { "contacts.create" }
      name { "Tạo Contact" }
      category { "Contacts" }
      initialize_with do
        Permission.find_or_create_by!(code: "contacts.create") do |p|
          p.name = "Tạo Contact"
          p.category = "Contacts"
        end
      end
    end

    trait :contacts_edit do
      code { "contacts.edit" }
      name { "Sửa Contact" }
      category { "Contacts" }
      initialize_with do
        Permission.find_or_create_by!(code: "contacts.edit") do |p|
          p.name = "Sửa Contact"
          p.category = "Contacts"
        end
      end
    end

    trait :contacts_pick do
      code { "contacts.pick" }
      name { "Pick Contact" }
      category { "Contacts" }
      initialize_with do
        Permission.find_or_create_by!(code: "contacts.pick") do |p|
          p.name = "Pick Contact"
          p.category = "Contacts"
        end
      end
    end

    # Roles permissions
    trait :roles_view do
      code { "roles.view" }
      name { "Xem Role" }
      category { "Roles" }
      initialize_with do
        Permission.find_or_create_by!(code: "roles.view") do |p|
          p.name = "Xem Role"
          p.category = "Roles"
        end
      end
    end

    trait :roles_manage do
      code { "roles.manage" }
      name { "Quản lý Role" }
      category { "Roles" }
      initialize_with do
        Permission.find_or_create_by!(code: "roles.manage") do |p|
          p.name = "Quản lý Role"
          p.category = "Roles"
        end
      end
    end

    # Reports permissions
    trait :reports_view do
      code { "reports.view" }
      name { "Xem Báo cáo" }
      category { "Reports" }
      initialize_with do
        Permission.find_or_create_by!(code: "reports.view") do |p|
          p.name = "Xem Báo cáo"
          p.category = "Reports"
        end
      end
    end
  end
end
