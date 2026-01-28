# frozen_string_literal: true

FactoryBot.define do
  factory :source do
    sequence(:name) { |n| "Nguồn #{n}" }
    description { "MyText" }
    active { false }
    position { 1 }
  end
end
