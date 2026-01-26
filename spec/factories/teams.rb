FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    region { %w[Bắc Trung Nam].sample }
    description { "Test Description" }
  end
end
