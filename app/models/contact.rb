# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id               :bigint           not null, primary key
#  code             :string(20)       not null (KH2026-XXX)
#  name             :string(100)      not null
#  phone            :string(20)       not null (UNIQUE)
#  email            :string(100)
#  zalo_link        :string(255)
#  service_type_id  :bigint           not null, FK → service_types
#  source           :integer          not null, default(0)
#  status           :integer          not null, default(0)
#  team_id          :bigint           FK → teams
#  assigned_user_id :bigint           FK → users
#  created_by_id    :bigint           not null, FK → users
#  assigned_at      :datetime
#  next_appointment :datetime
#  notes            :text
#  closed_at        :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_contacts_on_code                    (code) UNIQUE
#  index_contacts_on_phone                   (phone) UNIQUE
#  index_contacts_on_status                  (status)
#  index_contacts_on_source                  (source)
#  index_contacts_on_status_and_team         (status, team_id)
#  index_contacts_on_assignee_and_status     (assigned_user_id, status)
#  index_contacts_on_team_and_created_at     (team_id, created_at)
#  index_contacts_on_next_appointment        (next_appointment)
#

# TASK-019: Contact model - Main customer entity per SRS v2 Section 5
# rubocop:disable Metrics/ClassLength
class Contact < ApplicationRecord
  # TASK-051: State Machine for status transitions
  include StatusMachine

  # ============================================================================
  # Enums (SRS v2 Section 5.2 & 5.3)
  # ============================================================================

  # Trạng thái Contact (SRS v2 Section 5.3 - State Machine)
  enum :status, {
    new_contact: 0,       # Mới - Tổng đài vừa tạo
    potential: 1,         # Tiềm năng - Sale đã nhận
    in_progress: 2,       # Đang tư vấn
    potential_old: 3,     # Tiềm năng cũ - Qua tháng mới
    closed_new: 4,        # Chốt Mới - Thành công (trong tháng)
    closed_old: 5,        # Chốt Cũ - Thành công (từ tháng trước)
    failed: 6,            # Thất bại
    cskh_l1: 7,           # CSKH Level 1
    cskh_l2: 8,           # CSKH Level 2
    closed: 9             # Đóng - Kết thúc
  }, prefix: true

  # ============================================================================
  # Associations
  # ============================================================================

  belongs_to :service_type
  belongs_to :source
  belongs_to :team, optional: true
  belongs_to :assigned_user, class_name: "User", optional: true, inverse_of: :assigned_contacts
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :created_contacts

  # TASK-023: Care History / Interactions
  has_many :interactions, dependent: :destroy

  # TASK-035: Notifications referencing this contact
  has_many :notifications, as: :notifiable, dependent: :destroy

  # TASK-049: Zalo Integration
  has_one_attached :zalo_qr

  # ============================================================================
  # Validations
  # ============================================================================

  validates :name, presence: true, length: { maximum: 100 }

  # TASK-049: Dynamic Identity (Phone OR Zalo)
  # TASK-049: Dynamic Identity (Phone OR Zalo ID OR Zalo QR)
  validate :must_have_contact_info

  validates :phone, length: { minimum: 10, maximum: 20 }, allow_blank: true
  validates :phone, uniqueness: { message: "đã tồn tại trong hệ thống" }, allow_blank: true

  validates :zalo_id, uniqueness: { message: "Zalo ID này đã tồn tại" }, allow_blank: true
  validates :email, length: { maximum: 100 },
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :zalo_link, length: { maximum: 255 }
  validates :code, presence: true, uniqueness: true

  # TASK-049: Strict Validation for Required Fields
  validates :service_type_id, presence: { message: "không thể để trống" }
  # Validates presence of association
  validates :source, presence: { message: "không thể để trống" }

  # ============================================================================
  # Callbacks
  # ============================================================================

  before_validation :generate_code, on: :create
  before_validation :normalize_phone
  before_validation :normalize_zalo_id
  before_save :set_team_from_service_type, if: :service_type_id_changed?
  after_create :mark_as_just_created
  after_create :initialize_smart_routing
  after_save :set_assigned_at, if: :saved_change_to_assigned_user_id?

  # TASK-035: Real-time broadcasts
  after_create_commit :broadcast_contact_created
  after_update_commit :broadcast_contact_picked, if: :saved_change_to_assigned_user_id?

  # TASK-035: In-app notifications for Sales (included in broadcast_contact_created)

  # ============================================================================
  # Scopes
  # ============================================================================

  scope :unassigned, -> { where(assigned_user_id: nil) }
  scope :assigned, -> { where.not(assigned_user_id: nil) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_team, ->(team_id) { where(team_id: team_id) }
  scope :by_source, ->(source_id) { where(source_id: source_id) }
  scope :by_service_type, ->(service_type_id) { where(service_type_id: service_type_id) }
  scope :by_assignee, ->(user_id) { where(assigned_user_id: user_id) }
  scope :by_creator, ->(user_id) { where(created_by_id: user_id) }
  scope :with_appointment_in, lambda { |days|
    where(next_appointment: Time.current..days.days.from_now)
  }
  scope :recent, -> { order(created_at: :desc) }
  scope :prioritized, lambda {
    # Unassigned first, then by created_at desc
    order(Arel.sql("assigned_user_id IS NOT NULL, created_at DESC"))
  }

  # TASK-053: Smart Routing - Visible to specific users during working hours
  scope :visible_to, lambda { |user|
    # Pool pick mode (no restriction) or assigned contacts
    where(visible_to_user_ids: nil)
      .or(where("JSON_CONTAINS(visible_to_user_ids, ?)", user.id.to_s))
      .or(where(assigned_user_id: user.id))
  }

  # Search scope
  scope :search, lambda { |query|
    return all if query.blank?

    sanitized = "%#{sanitize_sql_like(query)}%"
    where("name LIKE ? OR phone LIKE ? OR code LIKE ?", sanitized, sanitized, sanitized)
  }

  # Contacts that need information update (missing email, notes, or old updates)
  scope :needs_info_update, lambda {
    where("email IS NULL OR email = '' OR notes IS NULL OR notes = '' OR updated_at < ?", 7.days.ago)
  }

  # ============================================================================
  # Class Methods
  # ============================================================================

  # Check if phone number already exists
  def self.phone_exists?(phone)
    normalized = phone.to_s.gsub(/\D/, "")
    exists?(phone: normalized)
  end

  # Find by phone (normalized)
  def self.find_by_phone(phone)
    normalized = phone.to_s.gsub(/\D/, "")
    find_by(phone: normalized)
  end

  # Normalize phone number (class method for controller use)
  def self.normalize_phone_number(phone)
    phone.to_s.gsub(/\D/, "")
  end

  # ============================================================================
  # Instance Methods
  # ============================================================================

  # Status display helpers
  def status_label
    I18n.t("contacts.status.#{status}", default: status.humanize)
  end

  def source_label
    source&.name || "N/A"
  end

  # Assignment helpers
  def assigned?
    assigned_user_id.present?
  end

  def unassigned?
    !assigned?
  end

  # Can be picked by a sale?
  def pickable?
    unassigned? && status_new_contact?
  end

  # Assign to a user
  def assign_to!(user)
    return false if assigned?

    update!(
      assigned_user_id: user.id,
      assigned_at: Time.current,
      status: :potential,
      visible_to_user_ids: nil,
      last_expanded_at: nil
    )
  end

  private

  # Generate unique code: KH2026-XXX
  def generate_code
    return if code.present?

    year = Time.current.year
    prefix = "KH#{year}-"

    # Find the last code for this year
    last_code = Contact.where("code LIKE ?", "#{prefix}%")
                       .order(code: :desc)
                       .pick(:code)

    if last_code
      last_number = last_code.gsub(prefix, "").to_i
      next_number = last_number + 1
    else
      next_number = 1
    end

    self.code = "#{prefix}#{next_number.to_s.rjust(5, '0')}"
  end

  # Normalize phone: remove all non-digits
  def normalize_phone
    self.phone = (phone.presence&.gsub(/\D/, ""))
  end

  # Normalize Zalo ID: treat blank as nil to avoid unique constraint violation
  def normalize_zalo_id
    self.zalo_id = nil if zalo_id.blank?
  end

  # Auto-assign team from service_type
  def set_team_from_service_type
    return unless service_type&.team_id

    self.team_id = service_type.team_id
  end

  # Track assignment timestamp
  def set_assigned_at
    return unless assigned_user_id.present? && assigned_at.blank?

    # Using update instead of update_column to follow Rails validations
    update(assigned_at: Time.current)
  end

  # Check validation: Must have at least one contact info
  def must_have_contact_info
    if phone.blank? && zalo_id.blank? && !zalo_qr.attached?
      errors.add(:base, "Phải nhập ít nhất một thông tin: SĐT, Zalo ID hoặc Zalo QR")
    end

    nil unless zalo_id.blank? && !zalo_qr.attached? && phone.blank?
    # Redundant check but keeps logic clear for individual fields if needed later
  end

  # TASK-035: Flag to track just-created records for callbacks
  def mark_as_just_created
    @just_created = true
  end

  def just_created?
    @just_created == true
  end

  # TASK-053: Initialize Smart Routing visibility on create
  def initialize_smart_routing
    SmartRoutingService.initialize_visibility(self)
  end

  # TASK-035: Broadcast new contact to visible users + create notifications
  def broadcast_contact_created
    # Skip in test environment (no Warden context for can? helper in partial)
    return if Rails.env.test?
    # Guard: Only run on actual CREATE, not on subsequent updates
    return unless just_created?

    # Clear flag immediately to prevent any duplicate calls
    @just_created = false

    # STEP 1: Create in-app notifications for visible Sales
    NotificationService.notify_contact_created(self)

    # STEP 2: Broadcast badge update
    broadcast_notification_badge_update

    # STEP 3: Broadcast contact list update (prepend new contact to table)
    broadcast_contact_list_update

    Rails.logger.info "[Contact#broadcast_created] Contact #{id} - notifications, badge, and list updated"
  rescue StandardError => e
    Rails.logger.error "[Contact#broadcast_created] Error: #{e.message}"
  end

  # TASK-035: Broadcast contact picked - remove from other users' lists
  def broadcast_contact_picked
    return if Rails.env.test?
    return if assigned_user_id.blank?

    # Broadcast to global stream to remove this contact from all lists
    Turbo::StreamsChannel.broadcast_remove_to(
      "contacts_global",
      target: dom_id(self)
    )

    # Also broadcast to specific users who could see this contact before
    previous_visible_ids = visible_to_user_ids_before_last_save || []
    previous_visible_ids.each do |user_id|
      next if user_id == assigned_user_id # Don't remove from picker's list

      Turbo::StreamsChannel.broadcast_remove_to(
        "user_#{user_id}_contacts",
        target: dom_id(self)
      )
    end

    Rails.logger.info "[Contact#broadcast_picked] Contact #{id} picked by user #{assigned_user_id}"
  rescue StandardError => e
    Rails.logger.error "[Contact#broadcast_picked] Error: #{e.message}"
  end

  # Helper: Calculate which users can see this contact
  def calculate_visible_user_ids
    if visible_to_user_ids.present?
      # Smart Routing mode: specific users
      visible_to_user_ids
    else
      # Pool mode: all active sales users in the same team
      team_users = fetch_team_user_ids
      # Also include super admins (they can see all)
      admin_ids = User.joins(:roles).where(roles: { code: Role::SUPER_ADMIN }).active.distinct.pluck(:id)
      (team_users + admin_ids).uniq
    end
  end

  def fetch_team_user_ids
    return [] unless team

    team.users.active.pluck(:id)
  end

  # Broadcast to update notification badge count for users
  def broadcast_notification_badge_update
    visible_user_ids = calculate_visible_user_ids
    return if visible_user_ids.empty?

    visible_user_ids.each do |user_id|
      unread_count = Notification.where(user_id: user_id).unread.count

      badge_html = if unread_count.positive?
                     display = unread_count > 9 ? "9+" : unread_count.to_s
                     %(<span id="notification_badge" class="absolute -top-1 -right-1 flex items-center ) +
                       %(justify-center h-5 w-5 rounded-full bg-brand-red text-white text-xs font-bold ) +
                       %(ring-2 ring-white">#{display}</span>)
                   else
                     # Hidden badge when no notifications
                     %(<span id="notification_badge" class="hidden"></span>)
                   end

      Turbo::StreamsChannel.broadcast_replace_to(
        "user_#{user_id}_notifications",
        target: "notification_badge",
        html: badge_html
      )
    end

    Rails.logger.info "[Contact#broadcast_badge] Badge updated for #{visible_user_ids.size} users"
  end

  # TASK-035: Broadcast new contact row to Sales Dashboard
  def broadcast_contact_list_update
    visible_user_ids = calculate_visible_user_ids
    return if visible_user_ids.empty?

    visible_user_ids.each do |user_id|
      # Broadcast to Sales Dashboard (new_contacts_table_body)
      Turbo::StreamsChannel.broadcast_prepend_to(
        "user_#{user_id}_contacts",
        target: "new_contacts_table_body",
        partial: "sales_workspace/contact_row_broadcast",
        locals: { contact: self }
      )
    end

    Rails.logger.info "[Contact#broadcast_list] Contact #{id} added to #{visible_user_ids.size} users' dashboards"
  end
end
# rubocop:enable Metrics/ClassLength
