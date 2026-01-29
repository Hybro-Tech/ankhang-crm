# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id          :bigint           not null, primary key
#  description :text(65535)
#  is_system   :boolean          default(FALSE)
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#
class Role < ApplicationRecord
  include RoleCodes

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: true

  before_update :check_system_role_for_update
  before_destroy :check_system_role_for_destroy

  # Dashboard type determines which dashboard view users with this role see
  # admin: Full admin dashboard with all stats
  # call_center: Focused on contact input and today's stats
  # sale: Pipeline, KPIs, and leaderboard
  # cskh: Customer care focused view
  enum :dashboard_type, { admin: 0, call_center: 1, sale: 2, cskh: 3 }

  def clone_with_permissions(new_name)
    new_role = dup
    new_role.name = new_name
    new_role.is_system = false
    new_role.save

    if new_role.persisted?
      permissions.each do |perm|
        new_role.permissions << perm
      end
    end

    new_role
  end

  private

  def check_system_role_for_destroy
    return unless is_system?

    errors.add(:base, "Không thể xóa system role")
    throw :abort
  end

  def check_system_role_for_update
    return unless is_system? && (name_changed? || is_system_changed?)

    errors.add(:base, "Không thể sửa tên hoặc trạng thái của system role")
    throw :abort
  end
end

#------------------------------------------------------------------------------
# Role
#
# Name        SQL Type             Null    Primary Default
# ----------- -------------------- ------- ------- ----------
# id          bigint               false   true
# name        varchar(255)         false   false
# description text                 true    false
# is_system   tinyint(1)           true    false   0
# created_at  datetime(6)          false   false
# updated_at  datetime(6)          false   false
#
#------------------------------------------------------------------------------
