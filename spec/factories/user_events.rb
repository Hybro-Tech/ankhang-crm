# frozen_string_literal: true

FactoryBot.define do
  factory :user_event do
    user
    event_type { "page_view" }
    path { "/contacts" }
    add_attribute(:method) { "GET" } # method is a reserved Ruby keyword
    controller { "ContactsController" }
    action { "index" }
    params { {} }
    response_status { 200 }
    duration_ms { 50 }
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    session_id { SecureRandom.hex(16) }
    request_id { SecureRandom.uuid }
  end
end
