# frozen_string_literal: true

# TASK-LOGGING: Admin Logs Controller
# Displays Activity Logs and User Events with filtering and export
# Access: super_admin only
module Admin
  class LogsController < ApplicationController
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

    def filtered_activity_logs
      logs = ActivityLog.all

      # Category filter
      logs = logs.where(category: params[:category]) if params[:category].present?

      # User filter
      logs = logs.where(user_id: params[:user_id]) if params[:user_id].present?

      # Action filter
      logs = logs.where("action LIKE ?", "%#{params[:action_filter]}%") if params[:action_filter].present?

      # Date range filter
      apply_date_filter(logs)
    end

    # rubocop:disable Metrics/AbcSize
    def filtered_user_events
      events = UserEvent.all

      # Event type filter
      events = events.where(event_type: params[:event_type]) if params[:event_type].present?

      # User filter
      events = events.where(user_id: params[:user_id]) if params[:user_id].present?

      # Path filter
      events = events.where("path LIKE ?", "%#{params[:path]}%") if params[:path].present?

      # Status filter
      events = events.where(response_status: params[:status]) if params[:status].present?

      # Date range filter
      apply_date_filter(events)
    end
    # rubocop:enable Metrics/AbcSize

    def apply_date_filter(scope)
      scope = scope.where(created_at: Date.parse(params[:date_from]).beginning_of_day..) if params[:date_from].present?
      scope = scope.where(created_at: ..Date.parse(params[:date_to]).end_of_day) if params[:date_to].present?
      scope
    end

    def export_activity_logs_csv
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << %w[ID User Action Category Subject IP CreatedAt]

        filtered_activity_logs.find_each do |log|
          csv << [
            log.id,
            log.user_name || log.user&.name,
            log.action,
            log.category,
            "#{log.subject_type}##{log.subject_id}",
            log.ip_address,
            log.created_at.strftime("%Y-%m-%d %H:%M:%S")
          ]
        end
      end
    end

    def export_user_events_csv
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << %w[ID User EventType Path Method Controller Action Status Duration IP CreatedAt]

        filtered_user_events.find_each do |event|
          csv << [
            event.id,
            event.user_id,
            event.event_type,
            event.path,
            event.method,
            event.controller,
            event.action,
            event.response_status,
            event.duration_ms,
            event.ip_address,
            event.created_at.strftime("%Y-%m-%d %H:%M:%S")
          ]
        end
      end
    end
  end
end
