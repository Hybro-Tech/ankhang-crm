# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    sequence(:name) { |n| "Khách hàng #{n}" }
    sequence(:phone) { |n| "09#{n.to_s.rjust(8, '0')}" }
    email { Faker::Internet.email }
    association :source
    status { :new_contact }

    association :service_type
    association :creator, factory: :user

    # code is auto-generated, no need to set

    trait :with_team do
      association :team
    end

    trait :assigned do
      association :assigned_user, factory: :user
      status { :potential }
      assigned_at { Time.current }
    end

    trait :in_progress do
      assigned
      status { :in_progress }
    end

    trait :closed_new do
      assigned
      status { :closed_new }
      closed_at { Time.current }
    end

    trait :failed do
      assigned
      status { :failed }
    end

    trait :with_appointment do
      next_appointment { 3.days.from_now }
    end
  end
end
