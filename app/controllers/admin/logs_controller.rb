# frozen_string_literal: true

# TASK-LOGGING: Admin Logs Controller
# Displays Activity Logs and User Events with filtering and export
# Access: super_admin only
module Admin
  class LogsController < ApplicationController
    include LogsFiltering
    include LogsExporting

    before_action :authenticate_user!
    before_action :authorize_admin!

    PER_PAGE = 50

    # GET /admin/logs
    # Shows activity logs (Tier 1)
    def index
      @logs = filtered_activity_logs
              .includes(:user, :subject)
              .order(created_at: :desc)
              .page(params[:page])
              .per(PER_PAGE)

      @categories = ActivityLog.distinct.pluck(:category).compact.sort
      @users = User.where(id: ActivityLog.distinct.select(:user_id)).order(:name)

      respond_to do |format|
        format.html
        format.csv { send_data export_activity_logs_csv, filename: "activity_logs_#{Date.current}.csv" }
      end
    end

    # GET /admin/logs/events
    # Shows user events (Tier 2)
    def events
      @events = filtered_user_events
                .includes(:user)
                .order(created_at: :desc)
                .page(params[:page])
                .per(PER_PAGE)

      @event_types = UserEvent.event_types.keys
      @users = User.where(id: UserEvent.distinct.select(:user_id)).order(:name)

      respond_to do |format|
        format.html
        format.csv { send_data export_user_events_csv, filename: "user_events_#{Date.current}.csv" }
      end
    end

    # GET /admin/logs/archives
    # Shows archived logs
    def archives
      @activity_archives = ActivityLogArchive.order(original_created_at: :desc)
                                             .page(params[:page])
                                             .per(PER_PAGE)

      @event_archives_count = UserEventArchive.count
      @activity_archives_count = ActivityLogArchive.count
    end

    # GET /admin/logs/:id
    # Shows single log detail in modal
    def show
      @log = ActivityLog.includes(:user, :subject).find(params[:id])

      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    private

    def authorize_admin!
      authorize! :manage, :logs
    end
  end
end
