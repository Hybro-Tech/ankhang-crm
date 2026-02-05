# frozen_string_literal: true

FactoryBot.define do
  factory :user_service_type_limit do
    association :user
    association :service_type
    max_pick_per_day { 10 }
  end
end
