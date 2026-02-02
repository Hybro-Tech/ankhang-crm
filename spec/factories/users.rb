# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  name                   :string(255)      default(""), not null
#  phone                  :string(255)      default("")
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  status                 :integer          default("active"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  team_id                :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}_#{SecureRandom.hex(4)}@test.com" }
    password { "password123" }
    name { Faker::Name.name }
    sequence(:username) { |n| "user_#{n}_#{SecureRandom.hex(4)}" }
    status { :active }

    trait :super_admin do
      after(:create) do |user|
        super_admin_role = Role.find_or_create_by!(name: "Super Admin") do |r|
          r.code = RoleCodes::SUPER_ADMIN
          r.dashboard_type = :admin
          r.is_system = true
        end
        # Ensure code is set even if role already exists without code
        super_admin_role.update!(code: RoleCodes::SUPER_ADMIN) if super_admin_role.code.blank?
        user.roles << super_admin_role unless user.roles.include?(super_admin_role)
      end
    end

    trait :call_center do
      after(:create) do |user|
        call_center_role = Role.find_or_create_by!(name: "Tổng đài") do |r|
          r.code = RoleCodes::CALL_CENTER
          r.dashboard_type = :call_center
          r.is_system = true
        end
        call_center_role.update!(code: RoleCodes::CALL_CENTER) if call_center_role.code.blank?
        user.roles << call_center_role unless user.roles.include?(call_center_role)

        # Add contacts.create permission (find first to avoid unique constraint violation)
        create_permission = Permission.find_by(code: "contacts.create") ||
                            Permission.create!(code: "contacts.create", name: "Tạo Contact")
        unless call_center_role.permissions.include?(create_permission)
          call_center_role.permissions << create_permission
        end
        view_permission = Permission.find_by(code: "contacts.view") ||
                          Permission.create!(code: "contacts.view", name: "Xem Contact")
        call_center_role.permissions << view_permission unless call_center_role.permissions.include?(view_permission)
      end
    end

    trait :sale do
      after(:create) do |user|
        sale_role = Role.find_or_create_by!(name: "Sale") do |r|
          r.code = RoleCodes::SALE
          r.dashboard_type = :sale
          r.is_system = true
        end
        sale_role.update!(code: RoleCodes::SALE) if sale_role.code.blank?
        user.roles << sale_role unless user.roles.include?(sale_role)

        # Add relevant permissions for Sale (find first to avoid unique constraint violation)
        %w[contacts.view contacts.edit contacts.pick].each do |perm_code|
          perm = Permission.find_by(code: perm_code) ||
                 Permission.create!(code: perm_code, name: perm_code.humanize)
          sale_role.permissions << perm unless sale_role.permissions.include?(perm)
        end
      end
    end

    trait :cskh do
      after(:create) do |user|
        cskh_role = Role.find_or_create_by!(name: "CSKH") do |r|
          r.code = RoleCodes::CSKH
          r.dashboard_type = :cskh
          r.is_system = true
        end
        cskh_role.update!(code: RoleCodes::CSKH) if cskh_role.code.blank?
        user.roles << cskh_role unless user.roles.include?(cskh_role)
      end
    end
  end
end
