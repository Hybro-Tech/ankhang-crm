# frozen_string_literal: true

class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  has_many :user_permissions, dependent: :destroy

  validates :subject, :action, presence: true
  validates :action, uniqueness: { scope: :subject }
end
