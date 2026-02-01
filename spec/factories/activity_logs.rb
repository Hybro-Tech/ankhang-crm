# frozen_string_literal: true

FactoryBot.define do
  factory :activity_log do
    user
    action { "create" }
    category { "contacts" }
    user_name { user&.name || "Test User" }
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    request_id { SecureRandom.uuid }

    trait :update_action do
      action { "update" }
      record_changes { { "status" => %w[new contacted] } }
    end

    trait :destroy_action do
      action { "destroy" }
    end

    trait :with_subject do
      association :subject, factory: :contact
    end
  end

  factory :activity_log_archive do
    user_id { nil }
    user_name { "Archived User" }
    action { "create" }
    category { "contacts" }
    ip_address { "127.0.0.1" }
    original_created_at { 8.months.ago }
  end
end
