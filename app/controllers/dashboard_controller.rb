# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @dashboard_view = current_user.primary_dashboard_type

    case @dashboard_view
    when "call_center"
      load_call_center_stats
      load_call_center_recent_contacts
      prepare_inline_form
    when "sale"
      load_sale_stats
      load_sales_data
    when "cskh"
      load_cskh_data
    else
      # Admin or fallback
      load_dashboard_stats
      load_recent_activities
      load_recent_contacts
      prepare_inline_form
    end
  end

  def call_center
    authorize! :view_call_center, :dashboards
    load_call_center_stats
    load_call_center_recent_contacts
    prepare_inline_form
    render :index
  end

  private

  # --- Admin / Generic ---
  def load_dashboard_stats
    @total_contacts = Contact.count
    @new_contacts_today = Contact.where(created_at: Time.zone.today.all_day).count
    @contacts_this_month = Contact.where(created_at: Time.zone.now.beginning_of_month..).count
    @contacts_growth = 12 # Mock
  end

  def load_recent_activities
    @recent_activities = [
      { icon: "fa-user-plus", color: "text-brand-blue", bg: "bg-blue-100", title: "Khách hàng mới",
        desc: "KH2026-099 đã được tạo.", time: "5 phút trước" },
      { icon: "fa-check-circle", color: "text-green-600", bg: "bg-green-100", title: "Chốt đơn thành công",
        desc: "HD-2026-001 - 15,000,000 ₫", time: "1 giờ trước" }
    ]
  end

  def load_recent_contacts
    @recent_contacts = Contact.includes(:assigned_user, :service_type)
                              .order(created_at: :desc)
                              .limit(5)
  end

  # --- Call Center ---
  def load_call_center_stats
    scope = current_user.created_contacts
    @contacts_today = scope.where(created_at: Time.zone.today.all_day).count
    @contacts_week = scope.where(created_at: Time.zone.now.beginning_of_week..).count
    @contacts_month = scope.where(created_at: Time.zone.now.beginning_of_month..).count
  end

  def load_call_center_recent_contacts
    @recent_contacts = current_user.created_contacts
                                   .includes(:service_type, :assigned_user)
                                   .order(created_at: :desc)
                                   .limit(10)
  end

  def prepare_inline_form
    @contact = Contact.new
    @service_types = ServiceType.for_dropdown
  end

  # --- Sale ---
  def load_sale_stats
    # Stats for Sale Dashboard
    @kpi = {
      total_contacts: current_user.assigned_contacts.count,
      new_leads: current_user.assigned_contacts.status_potential.count,
      won_deals_count: current_user.assigned_contacts.status_closed_new.count,
      revenue: 0,
      conversion_rate: 0
    }

    # Leaderboard (Mock for now to ensure UI renders)
    @top_performers = User.where(status: :active).limit(5).map do |user|
      {
        name: user.name,
        deals: rand(1..20),
        revenue: rand(10..500) * 1_000_000,
        avatar: "https://ui-avatars.com/api/?name=#{URI.encode_www_form_component(user.name)}&background=random"
      }
    end.sort_by { |u| -u[:deals] }
  end

  def load_sales_data
    # Upcoming Appointments
    @upcoming_appointments = current_user.assigned_contacts
                                         .where(next_appointment: Time.current..)
                                         .order(next_appointment: :asc)
                                         .limit(5)

    # Contacts to process (Assigned but not yet closed)
    # Priority: Potential > New
    @sales_contacts = current_user.assigned_contacts
                                  .where(status: %i[potential in_progress])
                                  .order(updated_at: :desc)
                                  .limit(10)

    # Recent Activities (Mock)
    @recent_activities = [
      { text: "KH2026-099 đã được gán cho bạn.", time: "5 phút trước", icon: "fa-user-plus", color: "text-brand-blue" },
      { text: "Lịch hẹn với KH2026-055 sắp đến.", time: "30 phút nữa", icon: "fa-clock", color: "text-orange-500" }
    ]

    # Chart Data (Mock)
    @chart_data = {
      labels: %w[Th2 Th3 Th4 Th5 Th6 Th7 CN],
      contacts: [12, 19, 3, 5, 2, 3, 15],
      deals: [2, 3, 1, 4, 1, 2, 5]
    }
  end

  # --- CSKH (Customer Care) ---
  def load_cskh_data
    # Failed contacts for customer care follow-up
    @failed_contacts = Contact.status_failed
                              .includes(:assigned_user, :service_type)
                              .order(updated_at: :desc)
                              .limit(20)

    # Stats
    @stats = {
      failed_today: Contact.status_failed.where(updated_at: Time.zone.today.all_day).count,
      pending_callback: Contact.status_failed.count,
      resolved_this_week: 0 # Placeholder for future
    }
  end
end
