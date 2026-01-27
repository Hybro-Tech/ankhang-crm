# frozen_string_literal: true

FactoryBot.define do
  factory :service_type do
    sequence(:name) { |n| "Loại nhu cầu #{n}" }
    description { "Mô tả loại nhu cầu" }
    active { true }
    position { 0 }

    trait :inactive do
      active { false }
    end

    trait :with_team do
      association :team
    end
  end
end
