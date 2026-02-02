# frozen_string_literal: true

# TASK-057: Service to create notifications
# Centralized notification creation with smart defaults
# rubocop:disable Metrics/ParameterLists
class NotificationService
  class << self
    # Create a single notification
    # rubocop:disable Metrics/CyclomaticComplexity
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
    # rubocop:enable Metrics/CyclomaticComplexity

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

    # Notify sales who can SEE the contact based on Smart Routing
    def notify_contact_created(contact)
      # Guard: Check if notification already exists for this contact
      return if Notification.exists?(notifiable: contact, notification_type: "contact_created")

      # Get visible user IDs from Smart Routing
      visible_user_ids = contact.visible_to_user_ids

      # If visible_to_user_ids is nil → Pool mode, notify all sales in team
      # If visible_to_user_ids is array → Only notify those specific users
      if visible_user_ids.blank?
        # Pool mode: all sales in team can see
        return if contact.team.blank?

        sales = contact.team.users.joins(:roles).where(roles: { code: Role::SALE })
      else
        # Smart Routing: only visible users
        sales = User.where(id: visible_user_ids)
      end

      return if sales.empty?

      notify_many(
        users: sales,
        type: "contact_created",
        notifiable: contact,
        metadata: {
          source: contact.source&.name,
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
      I18n.t("notifications.types.#{type}.title", default: I18n.t("notifications.default_title"))
    end

    def default_body(type, notifiable)
      return nil unless notifiable

      case type
      when "contact_created"
        I18n.t("notifications.types.contact_created.body",
               name: notifiable.name,
               service_type: notifiable.service_type&.name)
      when "contact_picked"
        I18n.t("notifications.types.contact_picked.body", name: notifiable.name)
      when "contact_assigned"
        I18n.t("notifications.types.contact_assigned.body", name: notifiable.name)
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
# rubocop:enable Metrics/ParameterLists
