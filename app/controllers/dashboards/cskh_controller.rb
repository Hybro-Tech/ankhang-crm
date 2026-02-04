# frozen_string_literal: true

# CSKH (Customer Service) Dashboard Controller
# TASK-064: Updated for simplified status (4 states)
# Handles dashboard for customer service staff managing recovery and after-sales
module Dashboards
  class CskhController < BaseController
    before_action :authorize_cskh!

    def show
      load_recovery_queue
      load_after_sales_queue
      load_stats
      load_zns_templates
    end

    private

    def authorize_cskh!
      authorize! :view_cskh, :dashboards
    end

    def load_recovery_queue
      @recovery_queue = Contact.status_failed
                               .includes(:assigned_user, :service_type)
                               .order(updated_at: :desc)
                               .limit(Setting.dashboard_top_limit * 2)
    end

    # TASK-064: Changed from status_closed to status_closed
    def load_after_sales_queue
      @after_sales_queue = Contact.status_closed
                                  .includes(:assigned_user, :service_type)
                                  .order(updated_at: :desc)
                                  .limit(Setting.dashboard_top_limit * 2)
    end

    def load_stats
      @stats = {
        failed_today: Contact.status_failed.where(updated_at: Time.zone.today.all_day).count,
        closed_today: Contact.status_closed.where(updated_at: Time.zone.today.all_day).count,
        pending_recovery: Contact.status_failed.count,
        avg_response_time: "15p" # Placeholder - Phase 2
      }
    end

    def load_zns_templates
      # Placeholder for ZNS integration - Phase 2
      @zns_templates = [
        { id: 1, name: "Cảm ơn mua hàng", status: "active" },
        { id: 2, name: "Chúc mừng sinh nhật", status: "active" },
        { id: 3, name: "Nhắc lịch hẹn", status: "pending" }
      ]
    end
  end
end
