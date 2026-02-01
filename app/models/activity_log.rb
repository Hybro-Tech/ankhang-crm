# frozen_string_literal: true

# == Schema Information
#
# Table name: activity_logs
#
#  id             :bigint           not null, primary key
#  user_id        :bigint
#  user_name      :string(100)      denormalized for display
#  action         :string(50)       not null
#  category       :string(20)       auth, contact, user, admin...
#  subject_type   :string
#  subject_id     :bigint
#  details        :json
#  record_changes :json             {old: {...}, new: {...}}
#  ip_address     :string(45)
#  user_agent     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_activity_logs_on_action                             (action)
#  index_activity_logs_on_category                           (category)
#  index_activity_logs_on_category_and_created_at            (category, created_at)
#  index_activity_logs_on_user_id_and_created_at             (user_id,created_at)
#  index_activity_logs_on_subject_and_created_at             (subject_type,subject_id,created_at)
#

class ActivityLog < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true, length: { maximum: 50 }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_category, ->(category) { where(category: category) }
  scope :in_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
end
