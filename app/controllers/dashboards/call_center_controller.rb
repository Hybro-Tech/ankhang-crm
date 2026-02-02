# frozen_string_literal: true

# Call Center Dashboard Controller
# Handles dashboard for call center operators who input contact data
module Dashboards
  class CallCenterController < BaseController
    before_action :authorize_call_center!

    def show
      load_kpi
      load_chart_data
      load_source_distribution
      load_recent_contacts
      prepare_inline_form
    end

    def stats
      @period = params[:period] || "month"
      load_kpi
      load_chart_data
      load_contacts_list
    end

    private

    def authorize_call_center!
      authorize! :view_call_center, :dashboards
    end

    def load_kpi
      scope = current_user.created_contacts
      @kpi = {
        today: scope.where(created_at: Time.zone.today.all_day).count,
        week: scope.where(created_at: Time.zone.now.beginning_of_week..).count,
        month: scope.where(created_at: Time.zone.now.beginning_of_month..).count,
        total: scope.count,
        daily_target: Setting.call_center_daily_target,
        progress: calculate_daily_progress(scope)
      }
    end

    def calculate_daily_progress(scope)
      today_count = scope.where(created_at: Time.zone.today.all_day).count
      target = Setting.call_center_daily_target
      [(today_count.to_f / target * 100).round, 100].min
    end

    def load_chart_data
      @chart_data = build_chart_data_for_range(current_user.created_contacts)
    end

    def load_source_distribution
      scope = current_user.created_contacts.where(created_at: Time.zone.now.beginning_of_month..)
      @source_distribution = Source.active
                                   .left_joins(:contacts)
                                   .where(contacts: { id: scope.select(:id) })
                                   .or(Source.active.where.missing(:contacts))
                                   .group("sources.id", "sources.name")
                                   .select("sources.name, COUNT(contacts.id) as contacts_count")
                                   .order(contacts_count: :desc)
                                   .limit(6)
                                   .map { |s| { name: s.name, count: s.contacts_count.to_i } }
    end

    def load_recent_contacts
      @recent_contacts = current_user.created_contacts
                                     .includes(:service_type, :assigned_user)
                                     .order(created_at: :desc)
                                     .limit(Setting.dashboard_top_limit * 2)
    end

    def prepare_inline_form
      @contact = Contact.new
      @service_types = ServiceType.for_dropdown
    end

    def load_contacts_list
      scope = filter_contacts_by_period(current_user.created_contacts)
      @contacts = scope.includes(:service_type, :assigned_user)
                       .order(created_at: :desc)
                       .page(params[:page]).per(20)
      @unassigned_contacts = current_user.created_contacts
                                         .where(assigned_user_id: nil)
                                         .order(created_at: :desc)
                                         .limit(Setting.dashboard_top_limit * 2)
    end

    def filter_contacts_by_period(scope)
      case @period
      when "today" then scope.where(created_at: Time.zone.today.all_day)
      when "week" then scope.where(created_at: Time.zone.now.beginning_of_week..)
      else scope.where(created_at: Time.zone.now.beginning_of_month..)
      end
    end
  end
end
