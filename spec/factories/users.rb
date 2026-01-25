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
    password { 'password123' }
    name { Faker::Name.name }
    sequence(:username) { |n| "user_#{n}_#{SecureRandom.hex(4)}" }
    status { :active }

    trait :super_admin do
      after(:create) do |user|
        super_admin_role = Role.find_or_create_by!(name: 'Super Admin', is_system: true)
        user.roles << super_admin_role unless user.roles.include?(super_admin_role)
      end
    end
  end
end
