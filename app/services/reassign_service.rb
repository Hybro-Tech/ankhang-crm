# frozen_string_literal: true

# TASK-052: ReassignService
# Executes the actual reassignment/unassignment when request is approved
class ReassignService
  def initialize(reassign_request)
    @request = reassign_request
  end

  # Execute the reassignment/unassignment
  # Called after Lead approves the request
  # @return [Boolean] true if successful
  def execute
    return false unless @request.approved?

    ActiveRecord::Base.transaction do
      if @request.reassign?
        execute_reassign
      else
        execute_unassign
      end

      log_activity
    end

    true
  rescue StandardError => e
    Rails.logger.error("[ReassignService] Failed: #{e.message}")
    false
  end

  private

  def execute_reassign
    @request.contact.update!(
      assigned_user_id: @request.to_user_id,
      assigned_at: Time.current
    )
  end

  def execute_unassign
    @request.contact.update!(
      assigned_user_id: nil,
      assigned_at: nil,
      status: :new_contact
    )

    # Re-run Smart Routing for the unassigned contact
    # This will make the contact visible to eligible sales reps again
    SmartRoutingService.initialize_visibility(@request.contact)
  end

  def log_activity
    action = @request.reassign? ? "reassign_approved" : "contact_unassigned"

    ActivityLog.create!(
      user: @request.approved_by,
      action: action,
      subject: @request.contact,
      details: build_activity_details
    )
  end

  def build_activity_details
    {
      request_id: @request.id,
      request_type: @request.request_type,
      from_user_id: @request.from_user_id,
      from_user_name: @request.from_user.name,
      to_user_id: @request.to_user_id,
      to_user_name: @request.to_user&.name,
      reason: @request.reason,
      approved_by_id: @request.approved_by_id,
      approved_by_name: @request.approved_by&.name
    }
  end
end
