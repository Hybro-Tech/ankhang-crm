# frozen_string_literal: true

class SaturdaySchedule < ApplicationRecord
  has_many :saturday_schedule_users, dependent: :destroy
  has_many :users, through: :saturday_schedule_users

  validates :date, presence: true, uniqueness: true
  validate :must_be_saturday, if: -> { date.present? }

  scope :upcoming, -> { where(date: Date.current..).order(date: :asc) }
  scope :past, -> { where(date: ...Date.current).order(date: :desc) }

  def self.registered?(date, user)
    return false unless user

    includes(:users).find_by(date: date)&.users&.include?(user) || false
  end

  private

  def must_be_saturday
    errors.add(:date, "phải là ngày Thứ Bảy") unless date.saturday?
  end
end
