# frozen_string_literal: true

FactoryBot.define do
  factory :holiday do
    name { "Holiday #{Faker::Name.name}" }
    date { Faker::Date.unique.between(from: 1.year.ago, to: 1.year.from_now) }
    description { "MyText" }
  end
end
