# frozen_string_literal: true

# WebPushService handles sending push notifications to users
# Uses VAPID protocol for secure browser push notifications
#
# Usage:
#   WebPushService.notify_user(user, title: "Hello", body: "World")
#   WebPushService.notify_users(users, title: "Hello", body: "World")
#
class WebPushService
  class << self
    # Send push notification to a specific user (all their devices)
    # @param user [User] The user to notify
    # @param title [String] Notification title
    # @param body [String] Notification body
    # @param options [Hash] Additional options (url, icon, tag, data)
    # @return [Integer] Number of successful deliveries
    def notify_user(user, title:, body:, **)
      return 0 unless vapid_configured?

      success_count = 0
      user.push_subscriptions.find_each do |subscription|
        success_count += 1 if subscription.send_notification(title: title, body: body, **)
      end

      Rails.logger.info "[WebPush] Sent to user #{user.id}: #{success_count}/#{user.push_subscriptions.count} devices"
      success_count
    end

    # Send push notification to multiple users
    # @param users [Array<User>, ActiveRecord::Relation] Users to notify
    # @param title [String] Notification title
    # @param body [String] Notification body
    # @param options [Hash] Additional options
    # @return [Integer] Total successful deliveries
    def notify_users(users, title:, body:, **)
      return 0 unless vapid_configured?

      total = 0
      users.includes(:push_subscriptions).find_each do |user|
        total += notify_user(user, title: title, body: body, **)
      end
      total
    end

    # Notify about new contact assignment (specific use case)
    # @param user [User] The sales person
    # @param contact [Contact] The assigned contact
    def notify_contact_assigned(user, contact)
      notify_user(
        user,
        title: "📞 Khách hàng mới",
        body: "#{contact.name || contact.phone} - #{contact.service_type&.name}",
        url: "/sales_workspace?tab=new_contacts",
        tag: "contact-#{contact.id}",
        data: { contact_id: contact.id }
      )
    end

    private

    def vapid_configured?
      config = Rails.application.config.x.vapid
      return false if config.blank?

      config[:public_key].present? && config[:private_key].present?
    end
  end
end
