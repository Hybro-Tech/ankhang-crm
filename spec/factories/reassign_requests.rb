# frozen_string_literal: true

FactoryBot.define do
  factory :reassign_request do
    association :contact
    association :from_user, factory: :user
    association :to_user, factory: :user
    association :requested_by, factory: :user

    reason { "Khách hàng yêu cầu đổi nhân viên phụ trách" }
    request_type { :reassign }
    status { :pending }

    trait :pending do
      status { :pending }
    end

    trait :approved do
      status { :approved }
      association :approved_by, factory: :user
      decided_at { Time.current }
    end

    trait :rejected do
      status { :rejected }
      association :approved_by, factory: :user
      decided_at { Time.current }
      rejection_reason { "Không đủ điều kiện" }
    end

    trait :reassign do
      request_type { :reassign }
      association :to_user, factory: :user
    end

    trait :unassign do
      request_type { :unassign }
      to_user { nil }
    end
  end
end
