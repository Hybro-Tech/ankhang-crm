# frozen_string_literal: true

# TASK-033: CrmMailer for Email Notifications
# Handles all CRM-related email notifications
class CrmMailer < ApplicationMailer
  default from: "AnKhangCRM <noreply@ankhangcrm.vn>"
  layout "crm_mailer"

  # Email khi Contact được gán cho Sale
  # @param contact [Contact] Contact được gán
  # @param assigned_user [User] Sale được gán
  def contact_assigned(contact, assigned_user)
    @contact = contact
    @user = assigned_user
    @action_url = contact_url(@contact)

    mail(
      to: @user.email,
      subject: "📋 Bạn được gán khách hàng mới: #{@contact.name}"
    )
  end

  # Email khi Admin tạo yêu cầu chuyển giao
  # @param reassign_request [ReassignRequest] Yêu cầu chuyển giao
  def reassign_request_created(reassign_request)
    @request = reassign_request
    @contact = reassign_request.contact
    @approver = reassign_request.approver
    @action_url = teams_reassign_requests_url

    return if @approver&.email.blank?

    mail(
      to: @approver.email,
      subject: "🔄 Yêu cầu duyệt chuyển giao: #{@contact.name}"
    )
  end

  # Email khi yêu cầu chuyển giao được duyệt
  # @param reassign_request [ReassignRequest] Yêu cầu đã duyệt
  def reassign_approved(reassign_request)
    @request = reassign_request
    @contact = reassign_request.contact
    @action_url = contact_url(@contact)

    recipients = build_approved_recipients(reassign_request)
    return if recipients.empty?

    mail(
      to: recipients,
      subject: "✅ Chuyển giao đã được duyệt: #{@contact.name}"
    )
  end

  # Email khi yêu cầu chuyển giao bị từ chối
  # @param reassign_request [ReassignRequest] Yêu cầu bị từ chối
  def reassign_rejected(reassign_request)
    @request = reassign_request
    @contact = reassign_request.contact
    @requester = reassign_request.requested_by
    @action_url = contacts_url

    return if @requester&.email.blank?

    mail(
      to: @requester.email,
      subject: "❌ Yêu cầu chuyển giao bị từ chối: #{@contact.name}"
    )
  end

  private

  def build_approved_recipients(request)
    recipients = []
    recipients << request.requested_by.email if request.requested_by&.email.present?
    recipients << request.from_user.email if request.from_user&.email.present?
    recipients << request.to_user.email if request.to_user&.email.present?
    recipients.uniq.compact
  end
end
