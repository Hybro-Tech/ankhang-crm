# frozen_string_literal: true

# Resolves action URLs for notifications based on type
# Extracted from Notification model to follow Single Responsibility Principle
class NotificationUrlResolver
  CONTACT_WORKSPACE_TYPES = %w[contact_created contact_picked contact_assigned].freeze
  CONTACT_DETAIL_TYPES = %w[contact_status_changed contact_reminder].freeze
  DEAL_TYPES = %w[deal_created deal_closed].freeze
  APPROVAL_TYPES = %w[reassign_requested reassign_approved reassign_rejected].freeze

  def self.resolve(notification)
    new(notification).resolve
  end

  def initialize(notification)
    @notification = notification
    @type = notification.notification_type
    @notifiable = notification.notifiable
  end

  def resolve
    return workspace_url if contact_workspace_type?
    return contact_detail_url if contact_detail_type?
    return deal_url if deal_type?
    return approval_url if approval_type?

    nil
  end

  private

  attr_reader :notification, :type, :notifiable

  def contact_workspace_type?
    CONTACT_WORKSPACE_TYPES.include?(type)
  end

  def contact_detail_type?
    CONTACT_DETAIL_TYPES.include?(type)
  end

  def deal_type?
    DEAL_TYPES.include?(type)
  end

  def approval_type?
    APPROVAL_TYPES.include?(type)
  end

  def workspace_url
    base_url = "/sales/workspace?tab=new_contacts"
    contact_id = notifiable.is_a?(Contact) ? notifiable.id : nil
    contact_id ? "#{base_url}&highlight=contact_#{contact_id}" : base_url
  end

  def contact_detail_url
    notifiable.is_a?(Contact) ? "/contacts/#{notifiable.id}" : "/sales/workspace"
  end

  def deal_url
    notifiable.is_a?(Deal) ? "/deals/#{notifiable.id}" : "/deals"
  end

  def approval_url
    "/admin/contacts"
  end
end
