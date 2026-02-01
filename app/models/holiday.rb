# frozen_string_literal: true

# == Schema Information
#
# Table name: holidays
#
#  id          :bigint           not null, primary key
#  name        :string(255)
#  date        :date
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_holidays_on_date  (date) UNIQUE
#
class Holiday < ApplicationRecord
  include Loggable

  # Validations
  validates :name, presence: true
  validates :date, presence: true, uniqueness: true

  # Scopes
  scope :upcoming, -> { where(date: Date.current..).order(date: :asc) }
  scope :past, -> { where(date: ...Date.current).order(date: :desc) }
  scope :in_year, ->(year) { where("YEAR(date) = ?", year).order(date: :asc) }

  # Class Methods

  # Check if a given date is a holiday
  # @param date [Date, String]
  # @return [Boolean]
  def self.holiday?(date)
    return false if date.blank?

    exists?(date: date)
  end
end
