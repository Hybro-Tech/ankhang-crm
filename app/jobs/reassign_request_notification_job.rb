# frozen_string_literal: true

# TASK-052: ReassignRequestNotificationJob
# Sends notifications to stakeholders when reassign request events occur
class ReassignRequestNotificationJob < ApplicationJob
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
    # Notify Lead (Manager of the team)
    if @request.approver.present?
      create_notification(
        recipient: @request.approver,
        title: "Yêu cầu #{request_type_label} cần duyệt",
        body: "#{@request.requested_by.name} yêu cầu #{request_type_label.downcase} " \
              "KH #{@request.contact.code} - #{@request.contact.name}",
        action_url: "/teams/reassign_requests"
      )
    end

    # Notify Sale A (current owner)
    create_notification(
      recipient: @request.from_user,
      title: "Có yêu cầu #{request_type_label.downcase} KH của bạn",
      body: "#{@request.requested_by.name} đã tạo yêu cầu #{request_type_label.downcase} " \
            "cho #{@request.contact.code}. Lý do: #{@request.reason.truncate(50)}",
      action_url: "/contacts/#{@request.contact_id}"
    )
  end

  def notify_on_approved
    # Notify Admin (requester)
    create_notification(
      recipient: @request.requested_by,
      title: "Yêu cầu #{request_type_label} đã được duyệt",
      body: "#{@request.approved_by&.name} đã duyệt yêu cầu cho " \
            "#{@request.contact.code} - #{@request.contact.name}",
      action_url: "/contacts/#{@request.contact_id}"
    )

    # Notify Sale A (previous owner)
    create_notification(
      recipient: @request.from_user,
      title: "KH #{@request.contact.code} đã được #{action_label}",
      body: approved_body_for_from_user,
      action_url: "/contacts/#{@request.contact_id}"
    )

    # Notify Sale B (new owner) - only for reassign
    return unless @request.reassign? && @request.to_user.present?

    create_notification(
      recipient: @request.to_user,
      title: "Bạn được gán KH mới",
      body: "#{@request.contact.code} - #{@request.contact.name} đã được chuyển cho bạn",
      action_url: "/contacts/#{@request.contact_id}"
    )
  end

  def notify_on_rejected
    # Notify Admin (requester)
    create_notification(
      recipient: @request.requested_by,
      title: "Yêu cầu #{request_type_label} bị từ chối",
      body: "#{@request.approved_by&.name} đã từ chối yêu cầu cho " \
            "#{@request.contact.code}. Lý do: #{@request.rejection_reason&.truncate(50)}",
      action_url: "/contacts/#{@request.contact_id}"
    )
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
    @request.reassign? ? "Chuyển KH" : "Gỡ KH"
  end

  def action_label
    @request.reassign? ? "chuyển đi" : "gỡ phân công"
  end

  def approved_body_for_from_user
    if @request.reassign?
      "Khách hàng đã được chuyển cho #{@request.to_user&.name}"
    else
      "Khách hàng đã được gỡ phân công và đưa về pool"
    end
  end
end
