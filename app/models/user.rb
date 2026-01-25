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
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums (TASK-007)
  enum :status, { active: 0, inactive: 1, locked: 2 }

  # Validations
  validates :name, presence: true

  # Associations (TASK-008)
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :user_permissions, dependent: :destroy
  # We might want direct permissions link later
end

#------------------------------------------------------------------------------
# User
#
# Name                   SQL Type             Null    Primary Default
# ---------------------- -------------------- ------- ------- ----------
# id                     bigint               false   true              
# email                  varchar(255)         false   false             
# encrypted_password     varchar(255)         false   false             
# name                   varchar(255)         false   false             
# phone                  varchar(255)         true    false             
# status                 int                  false   false   0         
# team_id                int                  true    false             
# reset_password_token   varchar(255)         true    false             
# reset_password_sent_at datetime(6)          true    false             
# remember_created_at    datetime(6)          true    false             
# created_at             datetime(6)          false   false             
# updated_at             datetime(6)          false   false             
#
#------------------------------------------------------------------------------
