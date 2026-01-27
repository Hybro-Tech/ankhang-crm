FactoryBot.define do
  factory :saturday_schedule do
    sequence(:date) { |n| Date.current.next_occurring(:saturday) + (7 * n).days }
    description { "Làm việc cuối tuần" }
  end
end
