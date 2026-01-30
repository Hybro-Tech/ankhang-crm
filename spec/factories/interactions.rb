# frozen_string_literal: true

FactoryBot.define do
  factory :interaction do
    association :contact
    association :user
    content { Faker::Lorem.sentence }
    interaction_method { :note }

    trait :call do
      interaction_method { :call }
    end

    trait :zalo do
      interaction_method { :zalo }
    end

    trait :email do
      interaction_method { :email }
    end

    trait :meeting do
      interaction_method { :meeting }
    end

    trait :appointment do
      interaction_method { :appointment }
      scheduled_at { 2.days.from_now }
    end
  end
end
