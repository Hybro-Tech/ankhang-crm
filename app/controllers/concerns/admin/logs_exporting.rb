# frozen_string_literal: true

# Concern for logs CSV export logic
# Extracted from LogsController to reduce class size
module Admin
  module LogsExporting
    extend ActiveSupport::Concern

    private

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
