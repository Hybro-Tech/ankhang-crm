# frozen_string_literal: true

# Concern for logs filtering logic
# Extracted from LogsController to reduce class size
module Admin
  module LogsFiltering
    extend ActiveSupport::Concern

    private

    def filtered_activity_logs
      logs = ActivityLog.all
      logs = logs.where(category: params[:category]) if params[:category].present?
      logs = logs.where(user_id: params[:user_id]) if params[:user_id].present?
      logs = logs.where("action LIKE ?", "%#{params[:action_filter]}%") if params[:action_filter].present?
      apply_date_filter(logs)
    end

    def filtered_user_events
      events = UserEvent.all
      events = apply_event_type_filter(events)
      events = apply_user_filter(events)
      events = apply_path_filter(events)
      events = apply_status_filter(events)
      apply_date_filter(events)
    end

    def apply_event_type_filter(scope)
      params[:event_type].present? ? scope.where(event_type: params[:event_type]) : scope
    end

    def apply_user_filter(scope)
      params[:user_id].present? ? scope.where(user_id: params[:user_id]) : scope
    end

    def apply_path_filter(scope)
      params[:path].present? ? scope.where("path LIKE ?", "%#{params[:path]}%") : scope
    end

    def apply_status_filter(scope)
      params[:status].present? ? scope.where(response_status: params[:status]) : scope
    end

    def apply_date_filter(scope)
      scope = scope.where(created_at: Date.parse(params[:date_from]).beginning_of_day..) if params[:date_from].present?
      scope = scope.where(created_at: ..Date.parse(params[:date_to]).end_of_day) if params[:date_to].present?
      scope
    end
  end
end
