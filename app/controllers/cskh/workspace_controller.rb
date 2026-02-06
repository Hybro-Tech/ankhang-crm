# frozen_string_literal: true

module Cskh
  # TASK-072: CSKH Workspace Controller
  # Main working screen for CSKH staff - manages blacklist and inspection
  # rubocop:disable Metrics/ClassLength
  class WorkspaceController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_cskh_user

    # GET /cskh/workspace
    def show
      load_kpis
      load_table_data
    end

    # GET /cskh/workspace/tab_blacklist (Turbo Frame)
    def tab_blacklist
      authorize! :tab_blacklist, :cskh_workspace
      load_tab_data(:blacklist)
      render partial: "blacklist_tab", locals: { contacts: @contacts }, layout: false
    end

    # GET /cskh/workspace/tab_aftercare (Turbo Frame)
    def tab_aftercare
      authorize! :tab_blacklist, :cskh_workspace # Reuse permission
      load_tab_data(:aftercare)
      render partial: "aftercare_tab", locals: { contacts: @contacts }, layout: false
    end

    # GET /cskh/workspace/tab_inspection (Turbo Frame)
    def tab_inspection
      authorize! :tab_inspection, :cskh_workspace
      load_tab_data(:inspection)
      render partial: "inspection_tab", locals: { contacts: @contacts }, layout: false
    end

    # POST /cskh/workspace/takeover/:id (TASK-074)
    def takeover
      authorize! :takeover, :cskh_workspace
      @contact = Contact.blacklist.find(params[:id])
      perform_takeover
      respond_to_takeover
    end

    private

    def perform_takeover
      old_user = @contact.assigned_user

      ActiveRecord::Base.transaction do
        @contact.update!(assigned_user: current_user, status: :potential, assigned_at: Time.current)
        log_takeover_activity(old_user)
      end
    end

    def log_takeover_activity(old_user)
      ActivityLog.create!(
        user: current_user,
        loggable: @contact,
        action: "cskh_takeover",
        changed_data: { from_user_id: old_user&.id, from_user_name: old_user&.name, to_user_id: current_user.id }
      )
    end

    def respond_to_takeover
      respond_to do |format|
        format.html { redirect_to cskh_workspace_path, notice: "Đã nhận chăm sóc #{@contact.code}" }
        format.turbo_stream { render_turbo_takeover }
      end
    end

    def render_turbo_takeover
      flash.now[:notice] = "Đã nhận chăm sóc #{@contact.code}"
      render turbo_stream: [
        turbo_stream.remove("contact_row_#{@contact.id}"),
        turbo_stream.update("flash", partial: "shared/flash")
      ]
    end

    def authorize_cskh_user
      authorize! :show, :cskh_workspace
    rescue CanCan::AccessDenied
      redirect_to root_path, alert: "Bạn không có quyền truy cập khu vực này."
    end

    # KPIs for dashboard header
    # rubocop:disable Metrics/AbcSize
    def load_kpis
      @failed_today_count = Contact.status_failed.where(updated_at: Time.current.all_day).count
      @stale_count = Contact.blacklist.where.not(status: :failed).count
      @closed_today_count = Contact.status_closed.where(closed_at: Time.current.all_day).count
      @avg_response_time = 15 # Placeholder - would need Interaction timing logic
      @inspection_count = Contact.long_appointment.count

      # Customer Health Score (placeholder logic - would need real business rules)
      total_assigned = Contact.assigned.count
      total_assigned = 1 if total_assigned.zero? # Avoid division by zero
      healthy = Contact.assigned.where.not(status: %i[failed]).where("last_interaction_at > ?", 24.hours.ago).count
      at_risk = Contact.assigned.where("last_interaction_at < ? AND last_interaction_at > ?", 24.hours.ago,
                                       72.hours.ago).count
      Contact.assigned.where(status: :failed).count
      Contact.assigned.where(last_interaction_at: ...72.hours.ago).count
      @health_healthy_pct = ((healthy.to_f / total_assigned) * 100).round
      @health_atrisk_pct = ((at_risk.to_f / total_assigned) * 100).round
      @health_critical_pct = (100 - @health_healthy_pct - @health_atrisk_pct).clamp(0, 100)
    end
    # rubocop:enable Metrics/AbcSize

    # Table data for main sections
    def load_table_data
      @blacklist_contacts = Contact.blacklist
                                   .includes(:assigned_user, :service_type)
                                   .order(updated_at: :desc)
      @closed_contacts = Contact.status_closed
                                .includes(:assigned_user, :service_type)
                                .where(closed_at: 30.days.ago..)
                                .order(closed_at: :desc)
    end

    # rubocop:disable Metrics/AbcSize
    def load_tab_data(tab)
      @contacts = case tab
                  when :blacklist
                    Contact.blacklist.includes(:assigned_user, :service_type, :source)
                           .order(updated_at: :desc).page(params[:page]).per(20)
                  when :aftercare
                    Contact.status_closed.includes(:assigned_user, :service_type, :source)
                           .where(closed_at: 30.days.ago..)
                           .order(closed_at: :desc).page(params[:page]).per(20)
                  when :inspection
                    Contact.long_appointment.includes(:assigned_user, :service_type, :source)
                           .order(next_appointment: :asc).page(params[:page]).per(20)
                  else
                    Contact.none.page(1)
                  end

      @current_tab = tab
    end
    # rubocop:enable Metrics/AbcSize
  end
  # rubocop:enable Metrics/ClassLength
end
