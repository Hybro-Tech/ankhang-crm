# frozen_string_literal: true

FactoryBot.define do
  factory :user_event_archive do
    user_id { nil }
    event_type { "page_view" }
    path { "/contacts" }
    add_attribute(:method) { "GET" }
    controller { "ContactsController" }
    action { "index" }
    params { {} }
    response_status { 200 }
    duration_ms { 50 }
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0" }
    session_id { SecureRandom.hex(16) }
    request_id { SecureRandom.uuid }
    original_created_at { 100.days.ago }
  end
end
