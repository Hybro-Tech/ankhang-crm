# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: true

  before_destroy :check_system_role_for_destroy
  before_update :check_system_role_for_update

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
    if is_system?
      errors.add(:base, "Không thể xóa system role")
      throw :abort
    end
  end

  def check_system_role_for_update
    if is_system? && (name_changed? || is_system_changed?)
      errors.add(:base, "Không thể sửa tên hoặc trạng thái của system role")
      throw :abort
    end
  end
end
