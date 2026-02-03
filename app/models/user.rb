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
  # TASK-LOGGING: Auto-log CRUD operations
  # Skip Devise trackable fields to avoid duplicate logs on login
  # (login/logout already logged separately via SessionsController)
  include Loggable

  loggable category: "user", skip_fields: %w[
    sign_in_count current_sign_in_at last_sign_in_at
    current_sign_in_ip last_sign_in_ip
  ]

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

  # TASK-048: Saturday Schedule
  has_many :saturday_schedule_users, dependent: :destroy
  has_many :saturday_schedules, through: :saturday_schedule_users

  # TASK-019: Contact relationships
  has_many :assigned_contacts, class_name: "Contact", foreign_key: :assigned_user_id,
                               inverse_of: :assigned_user, dependent: :nullify
  has_many :created_contacts, class_name: "Contact", foreign_key: :created_by_id,
                              inverse_of: :creator, dependent: :restrict_with_error

  # TASK-057: Notifications
  has_many :notifications, dependent: :destroy

  # TASK-056: Web Push Subscriptions
  has_many :push_subscriptions, dependent: :destroy

  # TASK-REGION: User's region/area for business purposes
  belongs_to :region, optional: true

  # TASK-PROFILE: Avatar attachment via Active Storage
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100]
    attachable.variant :medium, resize_to_fill: [200, 200]
  end

  # Avatar validation
  validate :avatar_format_and_size

  def avatar_format_and_size
    return unless avatar.attached?

    unless avatar.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:avatar, "phải là file ảnh (JPEG, PNG, GIF, WEBP)")
    end

    return unless avatar.byte_size > 5.megabytes

    errors.add(:avatar, "không được lớn hơn 5MB")
  end

  # Helper to get avatar URL or default
  def avatar_url(variant: :medium)
    return unless avatar.attached?

    avatar.variant(variant)
  end

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

  # Check if user has role by code (preferred for system checks)
  def has_role_code?(role_code)
    roles.exists?(code: role_code)
  end

  # Check if user is Super Admin
  def super_admin?
    has_role_code?(Role::SUPER_ADMIN)
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
  alias has_permission? can_access?

  # Get primary dashboard type from user's first role (ordered by id for determinism)
  # Defaults to "admin" if no role assigned
  def primary_dashboard_type
    roles.order(:id).first&.dashboard_type || "admin"
  end

  # TASK-Refine: Robust Role Checks (Enum-based)
  def call_center_staff?
    roles.exists?(dashboard_type: :call_center)
  end

  def sale_staff?
    roles.exists?(dashboard_type: :sale)
  end

  def cskh_staff?
    roles.exists?(dashboard_type: :cskh)
  end

  def admin?
    primary_dashboard_type == "admin"
  end

  # TASK-052: Check if user is a Team Leader (Manager)
  def team_leader?
    managed_team.present?
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
