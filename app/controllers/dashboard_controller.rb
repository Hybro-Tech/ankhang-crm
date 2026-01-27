# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    load_dashboard_stats
    load_recent_activities
    load_recent_contacts
    prepare_inline_form
  end

  def call_center
    authorize! :view_call_center, :dashboards
    load_call_center_stats
    load_call_center_recent_contacts
    prepare_inline_form
  end

  private

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

  def prepare_inline_form
    @contact = Contact.new
    @service_types = ServiceType.for_dropdown
  end

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
end
