# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DashboardController < ApplicationController
  include DashboardMockData

  before_action :authenticate_user!

  def index
    # Authorize based on user's primary dashboard type
    authorize_dashboard_access!

    # TASK-Refine: Sale staff accessing root ('/') should be redirected to Workspace
    # They can still view Overview at 'dashboard/index'
    handle_sale_redirect and return if performed?

    @dashboard_view = current_user.primary_dashboard_type
    load_dashboard_data
  end

  def call_center
    authorize! :view_call_center, :dashboards
    @dashboard_view = "call_center"
    load_dashboard_data
    render :index
  end

  def call_center_stats
    authorize! :view_call_center, :dashboards
    @period = params[:period] || "month"
    load_call_center_kpi
    load_call_center_chart_data
    load_call_center_contacts_list
  end

  private

  def handle_sale_redirect
    return unless current_user.sale_staff? && request.path == root_path

    redirect_to sales_workspace_path
  end

  # Authorize dashboard access based on user's primary dashboard type
  # Maps dashboard_type to corresponding permission: view_call_center, view_sales, etc.
  DASHBOARD_PERMISSIONS = {
    "admin" => :view_admin,
    "call_center" => :view_call_center,
    "sale" => :view_sales,
    "cskh" => :view_cskh
  }.freeze

  def authorize_dashboard_access!
    dashboard_type = current_user.primary_dashboard_type
    action = DASHBOARD_PERMISSIONS[dashboard_type] || :view_admin

    authorize! action, :dashboards
  end

  def load_dashboard_data
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
      @recent_activities = mock_recent_activities
      load_recent_contacts
      prepare_inline_form
    end
  end

  # --- Admin / Generic ---
  def load_dashboard_stats
    @kpi = build_admin_kpi
    @team_stats = build_team_stats
    @sales_stats = build_sales_stats
    @chart_data = build_admin_chart_data
    @top_performers = mock_top_performers
  end

  def build_admin_kpi
    {
      total_contacts: Contact.count,
      total_employees: User.count,
      contacts_this_month: Contact.where(created_at: Time.zone.now.beginning_of_month..).count,
      won_deals_count: Contact.status_closed_new.count,
      revenue: 0, # TODO: Calculate from Deal model when implemented
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

  def load_call_center_kpi
    scope = current_user.created_contacts
    @kpi = {
      today: scope.where(created_at: Time.zone.today.all_day).count,
      week: scope.where(created_at: Time.zone.now.beginning_of_week..).count,
      month: scope.where(created_at: Time.zone.now.beginning_of_month..).count,
      total: scope.count,
      daily_target: 50, # TODO: Make configurable
      progress: calculate_daily_progress(scope)
    }
  end

  def calculate_daily_progress(scope)
    today_count = scope.where(created_at: Time.zone.today.all_day).count
    target = 50 # TODO: Make configurable
    [(today_count.to_f / target * 100).round, 100].min
  end

  def load_call_center_chart_data
    date_range = 7.days.ago.to_date.upto(Date.current)
    scope = current_user.created_contacts
    @chart_data = {
      labels: date_range.map { |d| d.strftime("%d/%m") },
      data: date_range.map { |date| scope.where(created_at: date.all_day).count }
    }
  end

  def load_call_center_contacts_list
    scope = filter_contacts_by_period(current_user.created_contacts)
    @contacts = scope.includes(:service_type, :assigned_user)
                     .order(created_at: :desc)
                     .page(params[:page]).per(20)
    @unassigned_contacts = current_user.created_contacts
                                       .where(assigned_user_id: nil)
                                       .order(created_at: :desc)
                                       .limit(10)
  end

  def filter_contacts_by_period(scope)
    case @period
    when "today" then scope.where(created_at: Time.zone.today.all_day)
    when "week" then scope.where(created_at: Time.zone.now.beginning_of_week..)
    else scope.where(created_at: Time.zone.now.beginning_of_month..)
    end
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
    @top_performers = mock_top_performers
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

    @recent_activities = mock_sale_activities
    @chart_data = mock_chart_data
  end

  # --- CSKH (Customer Care) ---
  def load_cskh_data
    # 1. Recovery Queue (Failed contacts needing care)
    @recovery_queue = Contact.status_failed
                             .includes(:assigned_user, :service_type)
                             .order(updated_at: :desc)
                             .limit(10)

    # 2. After-Sales Queue (Closed contacts for follow-up)
    @after_sales_queue = Contact.status_closed_new
                                .includes(:assigned_user, :service_type)
                                .order(updated_at: :desc)
                                .limit(10)

    # Stats for CSKH
    @stats = {
      failed_today: Contact.status_failed.where(updated_at: Time.zone.today.all_day).count,
      closed_today: Contact.status_closed_new.where(updated_at: Time.zone.today.all_day).count,
      pending_recovery: Contact.status_failed.count,
      avg_response_time: "15p" # Placeholder
    }

    # ZNS Templates (Placeholder for now)
    @zns_templates = [
      { id: 1, name: "Cảm ơn mua hàng", status: "active" },
      { id: 2, name: "Chúc mừng sinh nhật", status: "active" },
      { id: 3, name: "Nhắc lịch hẹn", status: "pending" }
    ]
  end
end
# rubocop:enable Metrics/ClassLength
