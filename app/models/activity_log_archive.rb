# frozen_string_literal: true

# TASK-LOGGING: Archive model for Tier 1 Business Activity Logs
# Stores logs older than 6 months for permanent retention
class ActivityLogArchive < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  # Scopes
  scope :recent, -> { order(original_created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_category, ->(category) { where(category: category) }
  scope :in_date_range, ->(start_date, end_date) { where(original_created_at: start_date..end_date) }
end
