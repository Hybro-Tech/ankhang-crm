# frozen_string_literal: true

# == Schema Information
#
# Table name: permissions
#
#  id          :bigint           not null, primary key
#  category    :string(255)
#  code        :string(255)      not null
#  description :text(65535)
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_permissions_on_code  (code) UNIQUE
#
class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  has_many :user_permissions, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  # Group permissions by category for matrix display
  # Returns Hash { category_name => [permissions] }
  def self.grouped_by_category
    order(:category, :code).group_by(&:category)
  end

  # Extract action from code (e.g., "contacts.view" -> "view")
  def action
    code.split('.').last
  end

  # Extract subject from code (e.g., "contacts.view" -> "contacts")
  def subject
    code.split('.').first
  end
end

#------------------------------------------------------------------------------
# Permission
#
# Name        SQL Type             Null    Primary Default
# ----------- -------------------- ------- ------- ----------
# id          bigint               false   true              
# description text                 true    false             
# created_at  datetime(6)          false   false             
# updated_at  datetime(6)          false   false             
# code        varchar(255)         false   false             
# name        varchar(255)         true    false             
# category    varchar(255)         true    false             
#
#------------------------------------------------------------------------------
