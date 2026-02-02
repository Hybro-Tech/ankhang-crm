# frozen_string_literal: true

# TASK-052: ReassignRequestNotificationJob
# Sends notifications to stakeholders when reassign request events occur
class ReassignRequestNotificationJob < ApplicationJob # rubocop:disable Metrics/ClassLength
  queue_as :default

  # @param request_id [Integer] The ReassignRequest ID
  # @param event [String] The event type: 'created', 'approved', 'rejected'
  def perform(request_id, event)
    @request = ReassignRequest.find_by(id: request_id)
    return unless @request

    case event.to_s
    when "created"
      notify_on_created
    when "approved"
      notify_on_approved
    when "rejected"
      notify_on_rejected
    end
  end

  private

  def notify_on_created
    notify_approver_on_created
    notify_owner_on_created
    # TASK-033: Send email notification
    EmailNotificationService.notify_reassign_request_created(@request)
  end

  def notify_approver_on_created
    return if @request.approver.blank?

    create_notification(
      recipient: @request.approver,
      title: I18n.t("reassign_notifications.pending_approval", type: request_type_label),
      body: build_created_approver_body,
      action_url: "/teams/reassign_requests"
    )
  end

  def notify_owner_on_created
    create_notification(
      recipient: @request.from_user,
      title: I18n.t("reassign_notifications.request_on_your_contact", type: request_type_label.downcase),
      body: build_created_owner_body,
      action_url: "/contacts/#{@request.contact_id}"
    )
  end

  def build_created_approver_body
    I18n.t("reassign_notifications.request_created_body",
           requester: @request.requested_by.name,
           type: request_type_label.downcase,
           code: @request.contact.code,
           name: @request.contact.name)
  end

  def build_created_owner_body
    I18n.t("reassign_notifications.request_reason_body",
           requester: @request.requested_by.name,
           type: request_type_label.downcase,
           code: @request.contact.code,
           reason: @request.reason.truncate(50))
  end

  def notify_on_approved
    notify_requester_on_approved
    notify_previous_owner_on_approved
    notify_new_owner_on_approved
    # TASK-033: Send email notification
    EmailNotificationService.notify_reassign_approved(@request)
  end

  def notify_requester_on_approved
    create_notification(
      recipient: @request.requested_by,
      title: I18n.t("reassign_notifications.request_approved", type: request_type_label),
      body: I18n.t("reassign_notifications.approved_body",
                   approver: @request.approved_by&.name,
                   code: @request.contact.code,
                   name: @request.contact.name),
      action_url: "/contacts/#{@request.contact_id}"
    )
  end

  def notify_previous_owner_on_approved
    create_notification(
      recipient: @request.from_user,
      title: I18n.t("reassign_notifications.contact_transferred", code: @request.contact.code, action: action_label),
      body: approved_body_for_from_user,
      action_url: "/contacts/#{@request.contact_id}"
    )
  end

  def notify_new_owner_on_approved
    return unless @request.reassign? && @request.to_user.present?

    create_notification(
      recipient: @request.to_user,
      title: I18n.t("reassign_notifications.new_assignment"),
      body: I18n.t("reassign_notifications.new_assignment_body",
                   code: @request.contact.code,
                   name: @request.contact.name),
      action_url: "/contacts/#{@request.contact_id}"
    )
  end

  def notify_on_rejected
    # Notify Admin (requester)
    create_notification(
      recipient: @request.requested_by,
      title: I18n.t("reassign_notifications.request_rejected", type: request_type_label),
      body: I18n.t("reassign_notifications.rejected_body",
                   approver: @request.approved_by&.name,
                   code: @request.contact.code,
                   reason: @request.rejection_reason&.truncate(50)),
      action_url: "/contacts/#{@request.contact_id}"
    )
    # TASK-033: Send email notification
    EmailNotificationService.notify_reassign_rejected(@request)
  end

  def create_notification(recipient:, title:, body:, action_url:)
    Notification.create!(
      recipient: recipient,
      title: title,
      body: body,
      notifiable: @request,
      action_url: action_url
    )
  end

  def request_type_label
    @request.reassign? ? I18n.t("reassign_notifications.type_reassign") : I18n.t("reassign_notifications.type_unassign")
  end

  def action_label
    if @request.reassign?
      I18n.t("reassign_notifications.action_reassign")
    else
      I18n.t("reassign_notifications.action_unassign")
    end
  end

  def approved_body_for_from_user
    if @request.reassign?
      I18n.t("reassign_notifications.transferred_to", name: @request.to_user&.name)
    else
      I18n.t("reassign_notifications.unassigned")
    end
  end
end
