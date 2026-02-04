# frozen_string_literal: true

# Query Object for dashboard statistics
# Encapsulates complex dashboard queries with date range calculations
# TASK-064: Updated to use simplified status (status_closed)
# rubocop:disable Metrics/ClassLength
class DashboardStatsQuery
  def initialize(period: "month")
    @period = period
  end

  def kpi_stats
    {
      total_contacts: Contact.count,
      total_employees: User.where(status: :active).count,
      new_contacts: current_period_contacts,
      new_contacts_trend: contacts_trend,
      won_deals_count: current_period_closed,
      won_deals_trend: closed_trend,
      conversion_rate: conversion_rate
    }
  end

  def team_performance(limit: Setting.dashboard_top_limit)
    Team.left_joins(:service_types)
        .joins("LEFT JOIN contacts ON contacts.service_type_id = service_types.id")
        .group("teams.id", "teams.name")
        .select("teams.id, teams.name, COUNT(DISTINCT contacts.id) as contacts_count")
        .order(contacts_count: :desc)
        .limit(limit)
  end

  def sales_performance(limit: Setting.dashboard_top_limit)
    User.joins(:roles)
        .where(roles: { dashboard_type: :sale })
        .left_joins(:assigned_contacts)
        .group("users.id", "users.name")
        .select("users.id, users.name, COUNT(contacts.id) as contacts_count")
        .order(contacts_count: :desc)
        .limit(limit)
  end

  def top_performers(limit: Setting.dashboard_top_limit)
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
        .limit(limit)
  end

  def chart_data(days: Setting.dashboard_trend_days)
    date_range = days.days.ago.to_date.upto(Date.current)
    {
      labels: date_range.map { |d| d.strftime("%d/%m") },
      contacts: date_range.map { |date| Contact.where(created_at: date.all_day).count },
      deals: date_range.map { |date| Contact.status_closed.where(updated_at: date.all_day).count }
    }
  end

  def status_distribution
    Contact.group(:status).count
  end

  private

  def current_period_contacts
    Contact.where(created_at: current_range).count
  end

  def previous_period_contacts
    Contact.where(created_at: previous_range).count
  end

  def current_period_closed
    Contact.status_closed.where(updated_at: current_range).count
  end

  def previous_period_closed
    Contact.status_closed.where(updated_at: previous_range).count
  end

  def contacts_trend
    calculate_trend(current_period_contacts, previous_period_contacts)
  end

  def closed_trend
    calculate_trend(current_period_closed, previous_period_closed)
  end

  def conversion_rate
    total = Contact.count
    return 0 if total.zero?

    closed = Contact.status_closed.count
    ((closed.to_f / total) * 100).round(1)
  end

  def calculate_trend(current_value, previous_value)
    return 0 if previous_value.zero?

    ((current_value - previous_value).to_f / previous_value * 100).round(1)
  end

  def current_range
    case @period
    when "today"
      Time.zone.today.all_day
    when "week"
      Time.zone.now.beginning_of_week..Time.zone.now
    else
      Time.zone.now.beginning_of_month..Time.zone.now
    end
  end

  def previous_range
    case @period
    when "today"
      1.day.ago.all_day
    when "week"
      1.week.ago.all_week
    else
      1.month.ago.all_month
    end
  end
end
# rubocop:enable Metrics/ClassLength
