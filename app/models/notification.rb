# frozen_string_literal: true

# TASK-057: Notification model for in-app notifications
# Supports multi-channel delivery, polymorphic references, extensible metadata
class Notification < ApplicationRecord
  # === Categories ===
  CATEGORIES = {
    contact: "contact",
    deal: "deal",
    team: "team",
    system: "system",
    reminder: "reminder",
    approval: "approval"
  }.freeze

  # === Types per Category (icon, color defaults) ===
  NOTIFICATION_TYPES = {
    # Contact
    "contact_created" => { category: :contact, icon: "fa-user-plus", color: "blue" },
    "contact_picked" => { category: :contact, icon: "fa-hand-pointer", color: "green" },
    "contact_assigned" => { category: :contact, icon: "fa-user-tag", color: "purple" },
    "contact_status_changed" => { category: :contact, icon: "fa-sync", color: "orange" },
    "contact_reminder" => { category: :reminder, icon: "fa-bell", color: "yellow" },

    # Deal
    "deal_created" => { category: :deal, icon: "fa-handshake", color: "green" },
    "deal_closed" => { category: :deal, icon: "fa-check-circle", color: "green" },

    # Team
    "team_member_added" => { category: :team, icon: "fa-user-plus", color: "blue" },

    # Approval (Re-assign workflow)
    "reassign_requested" => { category: :approval, icon: "fa-exchange-alt", color: "orange" },
    "reassign_approved" => { category: :approval, icon: "fa-check", color: "green" },
    "reassign_rejected" => { category: :approval, icon: "fa-times", color: "red" },

    # System
    "system_announcement" => { category: :system, icon: "fa-bullhorn", color: "blue" },
    "system_maintenance" => { category: :system, icon: "fa-tools", color: "yellow" }
  }.freeze

  # === Associations ===
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  # === Validations ===
  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES.values }

  # === Scopes ===
  scope :unread, -> { where(read: false) }
  scope :unseen, -> { where(seen: false) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_dropdown, -> { recent.limit(20) }

  # === Callbacks ===
  before_create :set_defaults

  # === Instance Methods ===
  def mark_as_read!
    update!(read: true, read_at: Time.current) unless read?
  end

  def mark_as_seen!
    update!(seen: true, seen_at: Time.current) unless seen?
  end

  def type_config
    NOTIFICATION_TYPES[notification_type] || {}
  end

  def resolved_icon
    icon.presence || type_config[:icon] || "fa-bell"
  end

  def resolved_color
    icon_color.presence || type_config[:color] || "gray"
  end

  # Color class for Tailwind
  def color_class
    case resolved_color
    when "blue" then "text-blue-600 bg-blue-100"
    when "green" then "text-green-600 bg-green-100"
    when "red" then "text-red-600 bg-red-100"
    when "orange" then "text-orange-600 bg-orange-100"
    when "yellow" then "text-yellow-600 bg-yellow-100"
    when "purple" then "text-purple-600 bg-purple-100"
    else "text-gray-600 bg-gray-100"
    end
  end

  private

  def set_defaults
    config = type_config
    self.category ||= config[:category]&.to_s || "system"
    self.icon ||= config[:icon]
    self.icon_color ||= config[:color]
    self.metadata ||= {}
  end
end
