# frozen_string_literal: true

FactoryBot.define do
  factory :setting do
    key { "MyString" }
    value { "MyText" }
    description { "MyString" }
  end
end
