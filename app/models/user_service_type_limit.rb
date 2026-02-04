# frozen_string_literal: true

# == Schema Information
#
# Table name: user_service_type_limits
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  service_type_id  :bigint           not null
#  max_pick_per_day :integer          not null, default(10)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  idx_user_service_type_limits_unique (user_id, service_type_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_... (user_id => users.id)
#  fk_rails_... (service_type_id => service_types.id)
#

# TASK-062: Per-user pick limits by service type
class UserServiceTypeLimit < ApplicationRecord
  include Loggable

  loggable category: "user_service_type_limit"

  # Associations
  belongs_to :user
  belongs_to :service_type

  # Validations
  validates :max_pick_per_day, presence: true,
                               numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :user_id, uniqueness: { scope: :service_type_id, message: "đã có giới hạn cho loại nhu cầu này" }

  # Scopes
  scope :for_service_type, ->(service_type_id) { where(service_type_id: service_type_id) }
  scope :ordered, -> { includes(:service_type).order("service_types.name") }

  # Delegate for display
  delegate :name, to: :service_type, prefix: true

  # Check if user has reached daily limit
  def limit_reached?(date = Date.current)
    current_count = user.assigned_contacts
                        .where(service_type_id: service_type_id)
                        .where(assigned_at: date.all_day)
                        .count
    current_count >= max_pick_per_day
  end

  # Get remaining picks for today
  def remaining_picks(date = Date.current)
    current_count = user.assigned_contacts
                        .where(service_type_id: service_type_id)
                        .where(assigned_at: date.all_day)
                        .count
    [max_pick_per_day - current_count, 0].max
  end
end
