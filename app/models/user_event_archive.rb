# frozen_string_literal: true

# TASK-LOGGING: Archive model for Tier 2 User Event Logs
# Stores events older than 90 days for permanent retention
class UserEventArchive < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Scopes
  scope :recent, -> { order(original_created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_event_type, ->(type) { where(event_type: type) }
  scope :in_date_range, ->(start_date, end_date) { where(original_created_at: start_date..end_date) }
  scope :successful, -> { where(response_status: 200..299) }
  scope :errors, -> { where(response_status: 400..599) }
end
