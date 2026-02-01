# frozen_string_literal: true

# == Schema Information
#
# Table name: user_events
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           optional (null for anonymous)
#  event_type      :string(20)       page_view, api_call, form_submit, download
#  path            :string(500)      /contacts/123
#  method          :string(10)       GET, POST, PUT, DELETE
#  controller      :string(100)      ContactsController
#  action          :string(50)       show
#  params          :json             Sanitized request params
#  response_status :integer          200, 404, 500...
#  duration_ms     :integer          Response time in ms
#  ip_address      :string(45)
#  user_agent      :text
#  session_id      :string(100)
#  request_id      :string(50)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes:
#   index_user_events_on_user_id_and_created_at
#   index_user_events_on_event_type_and_created_at
#   index_user_events_on_created_at
#   index_user_events_on_request_id
#

# TASK-LOGGING: Tier 2 - User Event Logs
class UserEvent < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Enums
  enum :event_type, {
    page_view: "page_view",
    api_call: "api_call",
    form_submit: "form_submit",
    download: "download",
    ajax: "ajax"
  }, prefix: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_event_type, ->(type) { where(event_type: type) }
  scope :in_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :successful, -> { where(response_status: 200..299) }
  scope :errors, -> { where(response_status: 400..599) }
end
