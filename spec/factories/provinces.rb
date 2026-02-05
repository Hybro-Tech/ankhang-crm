# frozen_string_literal: true

FactoryBot.define do
  factory :province do
    sequence(:name) { |n| "Tỉnh #{n}" }
    sequence(:code) { |n| "PROVINCE_#{n}" }
    position { 1 }
    active { true }

    trait :with_region do
      after(:create) do |province, _evaluator|
        region = create(:region)
        province.regions << region
      end
    end
  end
end
