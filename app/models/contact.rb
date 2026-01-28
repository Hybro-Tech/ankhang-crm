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

  # Future: Contact History (TASK-023 or later)
  # has_many :contact_histories, dependent: :destroy

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
  after_save :set_assigned_at, if: :saved_change_to_assigned_user_id?

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
      status: :potential
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
end
# rubocop:enable Metrics/ClassLength
