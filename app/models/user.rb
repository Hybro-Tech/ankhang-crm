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
  # TASK-011: Devise modules
  # :lockable - khóa sau 5 lần fail (15 phút)
  # :timeoutable - session timeout sau 3 ngày
  # :trackable - theo dõi lịch sử đăng nhập
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :timeoutable, :trackable

  # Virtual attribute for authenticating by either username or email
  attr_accessor :login

  # Enums (TASK-007)
  enum :status, { active: 0, inactive: 1, locked: 2 }

  # Validations
  validates :name, presence: true
  validates :username, uniqueness: { case_sensitive: false }, allow_blank: true,
                       length: { minimum: 3, maximum: 50 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "chỉ cho phép chữ, số và dấu gạch dưới" }

  # Associations (TASK-008)
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :user_permissions, dependent: :destroy
  # We might want direct permissions link later

  # TASK-009: Team associations
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_one :managed_team, class_name: "Team", foreign_key: :manager_id,
                         inverse_of: :manager, dependent: :nullify

  # TASK-011: Allow login with username or email
  # Override Devise's find_for_database_authentication
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login) || conditions.delete(:email)

    if login.present?
      where("lower(email) = :value OR lower(username) = :value", value: login.downcase).first
    else
      where(conditions.to_h).first
    end
  end

  # Check if user can login (active status)
  def active_for_authentication?
    super && active?
  end

  # Custom message for inactive account
  def inactive_message
    active? ? super : :inactive
  end

  # ============================================================================
  # TASK-015: Authorization Helpers
  # ============================================================================

  # Check if user has specific role
  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  # Check if user is Super Admin
  def super_admin?
    has_role?("Super Admin")
  end

  # Get all effective permission codes (roles + overrides)
  # Used for view helpers and authorization checks
  def effective_permission_codes
    return Permission.pluck(:code) if super_admin?

    # Get permissions from roles
    role_codes = roles.eager_load(:permissions).flat_map { |r| r.permissions.pluck(:code) }

    # Apply user-level overrides
    granted_codes = user_permissions.where(granted: true)
                                    .joins(:permission)
                                    .pluck("permissions.code")
    denied_codes = user_permissions.where(granted: false)
                                   .joins(:permission)
                                   .pluck("permissions.code")

    ((role_codes + granted_codes) - denied_codes).uniq
  end

  # Check specific permission by code
  def can_access?(permission_code)
    effective_permission_codes.include?(permission_code)
  end
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
