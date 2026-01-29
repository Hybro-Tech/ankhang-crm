# frozen_string_literal: true

# TASK-057: Service to create notifications
# Centralized notification creation with smart defaults
class NotificationService
  class << self
    # Create a single notification
    def notify(user:, type:, notifiable: nil, title: nil, body: nil, metadata: {}, action_url: nil)
      config = Notification::NOTIFICATION_TYPES[type] || {}

      Notification.create!(
        user: user,
        notification_type: type,
        category: config[:category]&.to_s || "system",
        title: title || default_title(type, notifiable),
        body: body || default_body(type, notifiable),
        notifiable: notifiable,
        action_url: action_url || notifiable_url(notifiable),
        metadata: metadata || {}
      )
    end

    # Create notifications for multiple users
    def notify_many(users:, type:, notifiable: nil, title: nil, body: nil, metadata: {})
      users.find_each do |user|
        notify(
          user: user,
          type: type,
          notifiable: notifiable,
          title: title,
          body: body,
          metadata: metadata
        )
      end
    end

    # Notify all sales in a team about new contact
    def notify_contact_created(contact)
      return if contact.team.blank?

      sales = contact.team.users.joins(:roles).where(roles: { name: "Sale" })
      return if sales.empty?

      notify_many(
        users: sales,
        type: "contact_created",
        notifiable: contact,
        metadata: {
          source: contact.source,
          service_type_id: contact.service_type_id,
          created_by_id: contact.created_by_id
        }
      )
    end

    # Notify when contact is picked
    def notify_contact_picked(contact, picked_by:)
      # Notify the picker
      notify(
        user: picked_by,
        type: "contact_picked",
        notifiable: contact,
        title: "Đã nhận khách",
        body: "Bạn đã nhận #{contact.full_name}"
      )
    end

    private

    def default_title(type, _notifiable)
      case type
      when "contact_created" then "Khách hàng mới"
      when "contact_picked" then "Đã nhận khách"
      when "contact_assigned" then "Được gán khách mới"
      when "reassign_requested" then "Yêu cầu chuyển giao"
      when "reassign_approved" then "Đã phê duyệt chuyển giao"
      when "reassign_rejected" then "Từ chối chuyển giao"
      else "Thông báo"
      end
    end

    def default_body(type, notifiable)
      return nil unless notifiable

      case type
      when "contact_created"
        "#{notifiable.full_name} - #{notifiable.service_type&.name}"
      when "contact_picked"
        "#{notifiable.full_name} đã được nhận"
      when "contact_assigned"
        "Bạn được gán khách: #{notifiable.full_name}"
      end
    end

    def notifiable_url(notifiable)
      return nil unless notifiable

      case notifiable
      when Contact then "/contacts/#{notifiable.id}"
      when Deal then "/deals/#{notifiable.id}"
      end
    end
  end
end
