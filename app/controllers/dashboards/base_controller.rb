# frozen_string_literal: true

# Base concern for shared dashboard functionality
module Dashboards
  class BaseController < ApplicationController
    before_action :authenticate_user!

    protected

    def calculate_date_range(period)
      case period
      when "today"
        Time.zone.today.all_day
      when "week"
        Time.zone.now.beginning_of_week..Time.zone.now
      else
        Time.zone.now.beginning_of_month..Time.zone.now
      end
    end

    def calculate_previous_range(period)
      case period
      when "today"
        1.day.ago.all_day
      when "week"
        1.week.ago.all_week
      else
        1.month.ago.all_month
      end
    end

    def calculate_trend(current_value, previous_value)
      return 0 if previous_value.zero?

      ((current_value - previous_value).to_f / previous_value * 100).round(1)
    end

    def build_chart_data_for_range(scope, days: Setting.dashboard_trend_days)
      date_range = days.days.ago.to_date.upto(Date.current)
      {
        labels: date_range.map { |d| d.strftime("%d/%m") },
        data: date_range.map { |date| scope.where(created_at: date.all_day).count }
      }
    end
  end
end
