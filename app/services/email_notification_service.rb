# frozen_string_literal: true

# TASK-033: Email Notification Service
# Orchestrates sending email notifications with async delivery via Solid Queue
class EmailNotificationService
  class << self
    # Notify Sale when a contact is assigned to them
    # @param contact [Contact] The assigned contact
    def notify_contact_assigned(contact)
      return unless email_enabled?
      return if contact.assigned_user.blank?
      return unless should_send_email?(contact.assigned_user)

      CrmMailer.contact_assigned(contact, contact.assigned_user).deliver_later
      log_email_sent(:contact_assigned, contact.assigned_user, contact)
    end

    # Notify approver when a reassign request is created
    # @param reassign_request [ReassignRequest] The new request
    def notify_reassign_request_created(reassign_request)
      return unless email_enabled?
      return if reassign_request.approver.blank?
      return unless should_send_email?(reassign_request.approver)

      CrmMailer.reassign_request_created(reassign_request).deliver_later
      log_email_sent(:reassign_request_created, reassign_request.approver, reassign_request)
    end

    # Notify stakeholders when request is approved
    # @param reassign_request [ReassignRequest] The approved request
    def notify_reassign_approved(reassign_request)
      return unless email_enabled?

      recipients = build_approved_recipients(reassign_request)
      return if recipients.empty?

      CrmMailer.reassign_approved(reassign_request).deliver_later
      log_email_sent(:reassign_approved, recipients, reassign_request)
    end

    # Notify requester when request is rejected
    # @param reassign_request [ReassignRequest] The rejected request
    def notify_reassign_rejected(reassign_request)
      return unless email_enabled?
      return if reassign_request.requested_by.blank?
      return unless should_send_email?(reassign_request.requested_by)

      CrmMailer.reassign_rejected(reassign_request).deliver_later
      log_email_sent(:reassign_rejected, reassign_request.requested_by, reassign_request)
    end

    private

    # TASK-033: Check global email setting
    def email_enabled?
      Setting.email_notifications_enabled?
    end

    # Check if user wants to receive email notifications
    # Defaults to true if column doesn't exist yet
    def should_send_email?(user)
      return true unless user.respond_to?(:email_notifications_enabled)

      user.email_notifications_enabled != false
    end

    def build_approved_recipients(request)
      users = []
      users << request.requested_by if request.requested_by.present?
      users << request.from_user if request.from_user.present?
      users << request.to_user if request.to_user.present?
      users.uniq.select { |u| should_send_email?(u) }
    end

    def log_email_sent(type, recipient, notifiable)
      Rails.logger.info(
        "[EmailNotification] Sent #{type} to #{recipient_names(recipient)} " \
        "for #{notifiable.class.name}##{notifiable.id}"
      )
    end

    def recipient_names(recipient)
      case recipient
      when Array
        recipient.map(&:email).join(", ")
      when User
        recipient.email
      else
        recipient.to_s
      end
    end
  end
end
