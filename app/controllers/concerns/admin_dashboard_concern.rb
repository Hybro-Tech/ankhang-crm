# frozen_string_literal: true

# Admin Dashboard stats helper methods
module AdminDashboardConcern
  extend ActiveSupport::Concern

  private

  def load_admin_dashboard_data
    @kpi = build_admin_kpi
    @team_stats = build_team_stats
    @sales_stats = build_sales_stats
    @chart_data = build_admin_chart_data
    @top_performers = mock_top_performers
    @recent_activities = mock_recent_activities
  end

  def build_admin_kpi
    {
      total_contacts: Contact.count,
      total_employees: User.count,
      contacts_this_month: Contact.where(created_at: Time.zone.now.beginning_of_month..).count,
      won_deals_count: Contact.status_closed_new.count,
      revenue: Contact.status_closed_new.sum(:estimated_value).to_i,
      conversion_rate: calculate_conversion_rate
    }
  end

  def build_team_stats
    Team.left_joins(:service_types)
        .joins("LEFT JOIN contacts ON contacts.service_type_id = service_types.id")
        .group("teams.id", "teams.name")
        .select("teams.id, teams.name, COUNT(DISTINCT contacts.id) as contacts_count")
        .order(contacts_count: :desc)
        .limit(5)
  end

  def build_sales_stats
    User.joins(:roles)
        .where(roles: { dashboard_type: :sale })
        .left_joins(:assigned_contacts)
        .group("users.id", "users.name")
        .select("users.id, users.name, COUNT(contacts.id) as contacts_count")
        .order(contacts_count: :desc)
        .limit(5)
  end

  def build_admin_chart_data
    date_range = 7.days.ago.to_date.upto(Date.current)
    {
      labels: date_range.map { |d| d.strftime("%d/%m") },
      contacts: date_range.map { |date| Contact.where(created_at: date.all_day).count },
      deals: date_range.map { |date| Contact.status_closed_new.where(updated_at: date.all_day).count }
    }
  end

  def calculate_conversion_rate
    total = Contact.count
    return 0 if total.zero?

    closed = Contact.status_closed_new.count
    ((closed.to_f / total) * 100).round(1)
  end
end
