# frozen_string_literal: true

FactoryBot.define do
  factory :region do
    sequence(:name) { |n| "Region #{n}" }
    sequence(:code) { |n| "region_#{n}" }
    description { "Test region description" }
    position { 1 }
    active { true }
  end
end
