# frozen_string_literal: true

class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  has_many :user_permissions, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
