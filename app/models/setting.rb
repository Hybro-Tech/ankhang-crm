# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id          :bigint           not null, primary key
#  key         :string           not null
#  value       :text
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_settings_on_key  (key) UNIQUE
#

# TASK-053: System Settings for Smart Routing and other configs
# Key-value store for application settings
class Setting < ApplicationRecord
  # Validations
  validates :key, presence: true, uniqueness: true

  # Class methods for easy access
  class << self
    def get(key, default = nil)
      find_by(key: key)&.value || default
    end

    def set(key, value, description: nil)
      setting = find_or_initialize_by(key: key)
      setting.value = value.to_s
      setting.description = description if description
      setting.save!
      value
    end

    # Smart Routing Settings
    def working_hours_start
      get("working_hours_start", "08:00")
    end

    def working_hours_end
      get("working_hours_end", "17:30")
    end

    def saturday_hours_end
      get("saturday_hours_end", "11:30")
    end

    # Check if current time is within working hours
    def within_working_hours?(time = Time.current)
      return false if Holiday.exists?(date: time.to_date)

      day = time.wday
      return false if day.zero? # Sunday

      start_time = parse_time(working_hours_start, time)
      end_time = if day == 6 # Saturday
                   parse_time(saturday_hours_end, time)
                 else
                   parse_time(working_hours_end, time)
                 end

      time.between?(start_time, end_time)
    end

    private

    def parse_time(time_str, date)
      hours, minutes = time_str.split(":").map(&:to_i)
      date.change(hour: hours, min: minutes)
    end
  end

  # Default settings with descriptions
  DEFAULTS = {
    "working_hours_start" => { value: "08:00", description: "Giờ bắt đầu làm việc (T2-T6)" },
    "working_hours_end" => { value: "17:30", description: "Giờ kết thúc làm việc (T2-T6)" },
    "saturday_hours_end" => { value: "11:30", description: "Giờ kết thúc làm việc Thứ 7" }
  }.freeze

  # Seed default settings
  def self.seed_defaults!
    DEFAULTS.each do |key, config|
      find_or_create_by!(key: key) do |s|
        s.value = config[:value]
        s.description = config[:description]
      end
    end
  end
end
