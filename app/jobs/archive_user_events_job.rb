# frozen_string_literal: true

# TASK-LOGGING: Archive Tier 2 User Event Logs
# Moves events older than 90 days to archive table
# Scheduled to run monthly via Solid Queue recurring
class ArchiveUserEventsJob < ApplicationJob
  queue_as :default

  ARCHIVE_AFTER_DAYS = 90
  BATCH_SIZE = 5000

  def perform
    archived_count = 0

    UserEvent.where(created_at: ...ARCHIVE_AFTER_DAYS.days.ago)
             .find_in_batches(batch_size: BATCH_SIZE) do |batch|
               # Prepare records for archive
               archive_records = batch.map { |event| build_archive_record(event) }

               # Insert into archive table
               UserEventArchive.insert_all(archive_records) # rubocop:disable Rails/SkipsModelValidations

               # Delete from main table
               UserEvent.where(id: batch.map(&:id)).delete_all

               archived_count += batch.size
    end

    Rails.logger.info("[ArchiveUserEventsJob] Archived #{archived_count} records")
    archived_count
  end

  private

  def build_archive_record(event)
    {
      user_id: event.user_id,
      event_type: event.event_type,
      path: event.path,
      method: event.method,
      controller: event.controller,
      action: event.action,
      params: event.params,
      response_status: event.response_status,
      duration_ms: event.duration_ms,
      ip_address: event.ip_address,
      user_agent: event.user_agent,
      session_id: event.session_id,
      request_id: event.request_id,
      original_created_at: event.created_at,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
end
