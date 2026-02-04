# frozen_string_literal: true

# TASK-066: Background job to expand Smart Routing visibility layers
# Called after Layer 1 (Team) and Layer 2 (Regional) to progress to next layer
class SmartRoutingExpandJob < ApplicationJob
  queue_as :default

  # @param contact_id [Integer] Contact ID for expansion
  # @param user_id [Integer, nil] User who triggered the job (for logging)
  def perform(contact_id, user_id = nil)
    with_user_context(user_id)
    expand_contact(contact_id)
  end

  private

  def expand_contact(contact_id)
    contact = Contact.find_by(id: contact_id)
    return log_skip(contact_id, "not found") if contact.nil?
    return log_skip(contact_id, "already assigned") if contact.assigned_user_id.present?
    return log_skip(contact_id, "status changed") unless contact.status_new_contact?

    perform_expansion(contact)
  end

  def perform_expansion(contact)
    current_layer = contact.routing_layer || 1
    expanded = SmartRoutingService.expand_visibility_for(contact)

    Rails.logger.info "[SmartRouting] Contact #{contact.id} expansion from Layer #{current_layer}: #{expanded}"
  end

  def log_skip(contact_id, reason)
    Rails.logger.info "[SmartRouting] Contact #{contact_id} #{reason}, stopping job chain"
  end
end
