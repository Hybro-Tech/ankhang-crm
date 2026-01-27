# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Contacts Statistics
    @total_contacts = Contact.count
    @new_contacts_today = Contact.where(created_at: Time.zone.today.all_day).count
    @contacts_this_month = Contact.where(created_at: Time.zone.now.beginning_of_month..).count
    
    # Calculate percentage change (mock logic for now as we don't have enough history)
    @contacts_growth = 12 

    # Recent Activities (Mock for now, will replace with ActivityLog later)
    @recent_activities = [
      { 
        icon: "fa-user-plus", 
        color: "text-brand-blue", 
        bg: "bg-blue-100", 
        title: "Khách hàng mới", 
        desc: "KH2026-099 đã được tạo.", 
        time: "5 phút trước" 
      },
      { 
        icon: "fa-check-circle", 
        color: "text-green-600", 
        bg: "bg-green-100", 
        title: "Chốt đơn thành công", 
        desc: "HD-2026-001 - 15,000,000 ₫", 
        time: "1 giờ trước" 
      }
    ]

    # Recent Contacts Table
    @recent_contacts = Contact.includes(:assigned_user, :service_type)
                              .order(created_at: :desc)
                              .limit(5)

    # Inline Contact Form
    @contact = Contact.new
    @service_types = ServiceType.for_dropdown
  end

  def call_center
    authorize! :view_call_center, :dashboards

    # Stats for the current user (Call Center Staff)
    @contacts_today = current_user.created_contacts.where(created_at: Time.zone.today.all_day).count
    @contacts_week = current_user.created_contacts.where(created_at: Time.zone.now.beginning_of_week..).count
    @contacts_month = current_user.created_contacts.where(created_at: Time.zone.now.beginning_of_month..).count
    
    # Recent contacts created by me
    @recent_contacts = current_user.created_contacts.includes(:service_type, :assigned_user).order(created_at: :desc).limit(10)
    
    # Inline form
    @contact = Contact.new
    @service_types = ServiceType.for_dropdown
  end
end
