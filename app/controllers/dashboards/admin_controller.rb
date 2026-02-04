# frozen_string_literal: true

# Admin Dashboard Controller
# Handles dashboard for administrators showing system-wide statistics
module Dashboards
  class AdminController < BaseController
    before_action :authorize_admin!

    def show
      @period = params[:period] || "month"
      load_kpi
      load_team_stats
      load_sales_stats
      load_chart_data
      load_top_performers
      load_status_distribution
      load_recent_activities
      load_recent_contacts
    end

    private

    def authorize_admin!
      authorize! :view_admin, :dashboards
    end

    def load_kpi
      current_range = calculate_date_range(@period)
      previous_range = calculate_previous_range(@period)

      current_contacts = Contact.where(created_at: current_range).count
      previous_contacts = Contact.where(created_at: previous_range).count

      current_closed = Contact.status_closed.where(updated_at: current_range).count
      previous_closed = Contact.status_closed.where(updated_at: previous_range).count

      @kpi = {
        total_contacts: Contact.count,
        total_employees: User.where(status: :active).count,
        new_contacts: current_contacts,
        new_contacts_trend: calculate_trend(current_contacts, previous_contacts),
        won_deals_count: current_closed,
        won_deals_trend: calculate_trend(current_closed, previous_closed),
        revenue: 0, # Phase 2 - Deal model
        conversion_rate: calculate_conversion_rate
      }
    end

    def calculate_conversion_rate
      total = Contact.count
      return 0 if total.zero?

      closed = Contact.status_closed.count
      ((closed.to_f / total) * 100).round(1)
    end

    def load_team_stats
      @team_stats = Team.left_joins(:service_types)
                        .joins("LEFT JOIN contacts ON contacts.service_type_id = service_types.id")
                        .group("teams.id", "teams.name")
                        .select("teams.id, teams.name, COUNT(DISTINCT contacts.id) as contacts_count")
                        .order(contacts_count: :desc)
                        .limit(Setting.dashboard_top_limit)
    end

    def load_sales_stats
      @sales_stats = User.joins(:roles)
                         .where(roles: { dashboard_type: :sale })
                         .left_joins(:assigned_contacts)
                         .group("users.id", "users.name")
                         .select("users.id, users.name, COUNT(contacts.id) as contacts_count")
                         .order(contacts_count: :desc)
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

    def load_top_performers
      @top_performers = User.joins(:roles)
                            .where(roles: { dashboard_type: :sale }, status: :active)
                            .left_joins(:assigned_contacts)
                            .select(
                              "users.id",
                              "users.name",
                              "COUNT(contacts.id) as picked_count",
                              "SUM(CASE WHEN contacts.status = 'closed_new' THEN 1 ELSE 0 END) as closed_count"
                            )
                            .group("users.id, users.name")
                            .order(closed_count: :desc, picked_count: :desc)
                            .limit(Setting.dashboard_top_limit)
    end

    def load_status_distribution
      @status_distribution = Contact.group(:status).count
    end

    def load_recent_activities
      @recent_activities = ActivityLog.includes(:user, :subject)
                                      .order(created_at: :desc)
                                      .limit(Setting.dashboard_top_limit * 2)
    end

    def load_recent_contacts
      @recent_contacts = Contact.includes(:assigned_user, :service_type)
                                .order(created_at: :desc)
                                .limit(Setting.dashboard_top_limit)
    end
  end
end
