# frozen_string_literal: true

class SaturdayScheduleUser < ApplicationRecord
  belongs_to :saturday_schedule
  belongs_to :user

  validates :user_id, uniqueness: { scope: :saturday_schedule_id, message: "đã được thêm vào danh sách này" }
end
