# frozen_string_literal: true

# TASK-054: Background job to expand Smart Routing visibility
# Per-contact scheduled jobs with high precision timing
# Also supports batch expansion as fallback
class SmartRoutingExpandJob < ApplicationJob
  queue_as :default

  # @param contact_id [Integer, nil] Contact ID for per-contact expansion, nil for batch
  # @param user_id [Integer, nil] User who triggered the job (for logging)
  def perform(contact_id = nil, user_id = nil)
    with_user_context(user_id)

    if contact_id
      perform_for_contact(contact_id, user_id)
    else
      perform_batch_expansion
    end
  end

  private

  # TASK-054: Per-contact scheduled expansion
  # Called when contact is created, recursively schedules next expansion
  def perform_for_contact(contact_id, user_id)
    contact = Contact.find_by(id: contact_id)
    return log_skip(contact_id, "not found") if contact.nil?
    return log_skip(contact_id, "already assigned") if contact.assigned_user_id.present?
    return log_skip(contact_id, "status changed") unless contact.status_new_contact?

    expand_and_schedule_next(contact, user_id)
  end

  def expand_and_schedule_next(contact, user_id)
    expanded = SmartRoutingService.new(contact).expand_visibility
    Rails.logger.info "[SmartRouting] Contact #{contact.id} visibility expanded: #{expanded}"

    schedule_next_expansion(contact, user_id) if expanded
  end

  def schedule_next_expansion(contact, user_id)
    # TASK-060: Read from ENV instead of service_type column
    interval = ENV.fetch("VISIBILITY_EXPAND_MINUTES", 2).to_i
    self.class.set(wait: interval.minutes).perform_later(contact.id, user_id)
    Rails.logger.info "[SmartRouting] Scheduled next expansion for contact #{contact.id} in #{interval} minutes"
  end

  def log_skip(contact_id, reason)
    Rails.logger.info "[SmartRouting] Contact #{contact_id} #{reason}, stopping job chain"
  end

  # Legacy batch expansion - fallback for missed contacts
  def perform_batch_expansion
    Rails.logger.info "[SmartRouting] Running batch expansion for pending contacts..."
    SmartRoutingService.expand_all_pending
    Rails.logger.info "[SmartRouting] Batch expansion complete"
  end
end
