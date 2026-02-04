# frozen_string_literal: true

# Sales Dashboard Controller
# TASK-064: Updated for simplified status (4 states)
# Handles dashboard for sales staff showing their assigned contacts and performance
module Dashboards
  class SalesController < BaseController
    before_action :authorize_sales!

    def show
      load_kpi
      load_upcoming_appointments
      load_sales_contacts
      load_recent_activities
      load_chart_data
    end

    private

    def authorize_sales!
      authorize! :view_sales, :dashboards
    end

    def load_kpi
      @kpi = {
        total_contacts: current_user.assigned_contacts.count,
        new_leads: current_user.assigned_contacts.status_potential.count,
        won_deals_count: current_user.assigned_contacts.status_closed.count,
        revenue: 0, # Phase 2
        conversion_rate: calculate_conversion_rate
      }
      @top_performers = build_top_performers
    end

    def calculate_conversion_rate
      total = current_user.assigned_contacts.count
      return 0 if total.zero?

      closed = current_user.assigned_contacts.status_closed.count
      ((closed.to_f / total) * 100).round(1)
    end

    # TASK-064: Use integer value 3 for closed status
    def build_top_performers
      User.joins(:roles)
          .where(roles: { dashboard_type: :sale }, status: :active)
          .left_joins(:assigned_contacts)
          .select(
            "users.id",
            "users.name",
            "COUNT(contacts.id) as picked_count",
            "SUM(CASE WHEN contacts.status = 3 THEN 1 ELSE 0 END) as closed_count"
          )
          .group("users.id, users.name")
          .order(closed_count: :desc, picked_count: :desc)
          .limit(Setting.dashboard_top_limit)
    end

    def load_upcoming_appointments
      @upcoming_appointments = Interaction.interaction_method_appointment
                                          .joins(:contact)
                                          .where(contacts: { assigned_user_id: current_user.id })
                                          .where(scheduled_at: Time.current..)
                                          .order(scheduled_at: :asc)
                                          .includes(:contact)
                                          .limit(Setting.dashboard_top_limit)
    end

    # TASK-064: Simplified - only potential status
    def load_sales_contacts
      @sales_contacts = current_user.assigned_contacts
                                    .status_potential
                                    .order(updated_at: :desc)
                                    .limit(Setting.dashboard_top_limit * 2)
    end

    def load_recent_activities
      @recent_activities = ActivityLog.where(user: current_user)
                                      .where(created_at: Setting.dashboard_trend_days.days.ago..)
                                      .order(created_at: :desc)
                                      .limit(Setting.dashboard_top_limit)
    end

    def load_chart_data
      date_range = Setting.dashboard_trend_days.days.ago.to_date.upto(Date.current)
      @chart_data = {
        labels: date_range.map { |d| d.strftime("%d/%m") },
        contacts: date_range.map { |date| Contact.where(created_at: date.all_day).count },
        deals: date_range.map { |date| Contact.status_closed.where(updated_at: date.all_day).count }
      }
    end
  end
end
