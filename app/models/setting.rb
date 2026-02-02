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
  include Loggable

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

    # Timezone setting (default: Hanoi for Vietnam)
    def timezone
      get("timezone", "Hanoi")
    end

    # Check if current time is within working hours
    # Uses timezone from settings for calculation
    def within_working_hours?(time = nil)
      # Get time in the configured timezone
      tz = ActiveSupport::TimeZone[timezone] || ActiveSupport::TimeZone["Hanoi"]
      time ||= Time.current.in_time_zone(tz)

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

  DEFAULTS = {
    "working_hours_start" => { value: "08:00", description: "Giờ bắt đầu làm việc (T2-T6)" },
    "working_hours_end" => { value: "17:30", description: "Giờ kết thúc làm việc (T2-T6)" },
    "saturday_hours_end" => { value: "11:30", description: "Giờ kết thúc làm việc Thứ 7" },
    "timezone" => { value: "Hanoi", description: "Múi giờ hệ thống" },
    "call_center_daily_target" => { value: "50", description: "Chỉ tiêu liên hệ hàng ngày của Call Center" },
    "email_notifications_enabled" => { value: "false", description: "Bật/tắt gửi email thông báo" },
    # TASK-AUDIT: Centralized configuration for dashboard and monitoring
    "dashboard_trend_days" => { value: "7", description: "Số ngày hiển thị trend trên Dashboard" },
    "dashboard_top_limit" => { value: "5", description: "Số top performers hiển thị" },
    "kanban_column_limit" => { value: "20", description: "Giới hạn contacts mỗi cột Kanban" },
    "notification_dropdown_limit" => { value: "20", description: "Số notifications trong dropdown" },
    "monitoring_window_hours" => { value: "24", description: "Khoảng thời gian monitoring (giờ)" },
    "stale_contact_days" => { value: "7", description: "Số ngày contact bị coi là cũ" }
  }.freeze

  # Call Center Settings
  def self.call_center_daily_target
    get("call_center_daily_target", 50).to_i
  end

  # TASK-033: Email Notifications toggle
  def self.email_notifications_enabled?
    get("email_notifications_enabled", "false") == "true"
  end

  # TASK-AUDIT: Centralized configuration accessors
  def self.dashboard_trend_days
    get("dashboard_trend_days", 7).to_i
  end

  def self.dashboard_top_limit
    get("dashboard_top_limit", 5).to_i
  end

  def self.kanban_column_limit
    get("kanban_column_limit", 20).to_i
  end

  def self.notification_dropdown_limit
    get("notification_dropdown_limit", 20).to_i
  end

  def self.monitoring_window_hours
    get("monitoring_window_hours", 24).to_i
  end

  def self.stale_contact_days
    get("stale_contact_days", 7).to_i
  end

  # Available timezones for dropdown
  AVAILABLE_TIMEZONES = [
    ["Việt Nam (GMT+7)", "Hanoi"],
    ["Singapore (GMT+8)", "Singapore"],
    ["Tokyo (GMT+9)", "Asia/Tokyo"],
    ["UTC (GMT+0)", "UTC"]
  ].freeze

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
