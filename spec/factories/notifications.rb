# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    user
    title { "Test Notification" }
    body { "This is a test notification message" }
    category { "system" }
    notification_type { "system_announcement" }
    read { false }
    seen { false }

    trait :read do
      read { true }
      read_at { Time.current }
    end

    trait :unread do
      read { false }
      read_at { nil }
    end

    trait :seen do
      seen { true }
      seen_at { Time.current }
    end

    trait :with_action_url do
      action_url { "/contacts/1" }
    end
  end
end
