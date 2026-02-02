# frozen_string_literal: true

# == Schema Information
#
# Table name: interactions
#
#  id                 :bigint           not null, primary key
#  contact_id         :bigint           not null
#  user_id            :bigint           not null
#  content            :text             not null
#  interaction_method :integer          not null, default: 0
#  scheduled_at       :datetime         (for appointment type)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes:
#   index_interactions_on_contact_id_and_created_at
#

# TASK-023: Interaction model for contact care history
class Interaction < ApplicationRecord
  # TASK-LOGGING: Auto-log CRUD operations
  include Loggable

  loggable category: "interaction"
  # ============================================
  # Associations
  # ============================================
  belongs_to :contact
  belongs_to :user

  # ============================================
  # Enums
  # ============================================
  enum :interaction_method, {
    note: 0,
    call: 1,
    zalo: 2,
    email: 3,
    meeting: 4,
    appointment: 5
  }, prefix: true

  # ============================================
  # Validations
  # ============================================
  validates :content, presence: true
  validates :interaction_method, presence: true
  validates :scheduled_at, presence: true, if: :interaction_method_appointment?

  # ============================================
  # Callbacks
  # ============================================
  after_save :sync_appointment_to_contact, if: :interaction_method_appointment?

  # ============================================
  # Scopes
  # ============================================
  scope :recent, -> { order(created_at: :desc) }
  scope :by_method, ->(method) { where(interaction_method: method) }

  # ============================================
  # Instance Methods
  # ============================================

  # Display label for interaction method
  def method_label
    I18n.t("interactions.methods.#{interaction_method}", default: interaction_method.to_s.humanize)
  end

  # Icon class for timeline display
  def method_icon
    case interaction_method
    when "call" then "fa-solid fa-phone"
    when "zalo" then "fa-solid fa-comment"
    when "email" then "fa-solid fa-envelope"
    when "meeting" then "fa-solid fa-users"
    when "appointment" then "fa-solid fa-calendar-check"
    else "fa-solid fa-sticky-note"
    end
  end

  # Background color class for timeline icon
  def method_color_class
    case interaction_method
    when "call" then "bg-blue-100 text-blue-600"
    when "zalo" then "bg-teal-100 text-teal-600"
    when "email" then "bg-gray-100 text-gray-600"
    when "meeting" then "bg-green-100 text-green-600"
    when "appointment" then "bg-purple-100 text-purple-600"
    else "bg-yellow-100 text-yellow-600"
    end
  end

  private

  # Sync scheduled_at to contact.next_appointment
  def sync_appointment_to_contact
    return if scheduled_at.blank?
    return unless contact.next_appointment.nil? || scheduled_at > Time.current

    # Using update to follow Rails validations, though we're only updating a timestamp
    contact.update(next_appointment: scheduled_at)
  end
end
