# frozen_string_literal: true

# TASK-LOGGING: Archive Tier 1 Business Activity Logs
# Moves logs older than 6 months to archive table
# Scheduled to run monthly via Solid Queue recurring
class ArchiveActivityLogsJob < ApplicationJob
  queue_as :default

  ARCHIVE_AFTER_MONTHS = 6
  BATCH_SIZE = 1000

  def perform
    archived_count = 0

    ActivityLog.where(created_at: ...ARCHIVE_AFTER_MONTHS.months.ago)
               .find_in_batches(batch_size: BATCH_SIZE) do |batch|
                 # Prepare records for archive
                 archive_records = batch.map { |log| build_archive_record(log) }

                 # Insert into archive table
                 ActivityLogArchive.insert_all(archive_records) # rubocop:disable Rails/SkipsModelValidations

                 # Delete from main table
                 ActivityLog.where(id: batch.map(&:id)).delete_all

                 archived_count += batch.size
    end

    Rails.logger.info("[ArchiveActivityLogsJob] Archived #{archived_count} records")
    archived_count
  end

  private

  def build_archive_record(log)
    {
      user_id: log.user_id,
      user_name: log.user_name,
      action: log.action,
      category: log.category,
      subject_type: log.subject_type,
      subject_id: log.subject_id,
      details: log.details,
      record_changes: log.record_changes,
      ip_address: log.ip_address,
      user_agent: log.user_agent,
      request_id: log.request_id,
      original_created_at: log.created_at,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
end
