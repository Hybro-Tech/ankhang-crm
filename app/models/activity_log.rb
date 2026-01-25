# frozen_string_literal: true

# == Schema Information
#
# Table name: activity_logs
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  action       :string(50)       not null
#  subject_type :string
#  subject_id   :bigint
#  details      :json
#  ip_address   :string(45)
#  user_agent   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_activity_logs_on_action                             (action)
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
end
