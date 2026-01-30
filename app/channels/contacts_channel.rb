# frozen_string_literal: true

# TASK-035: Contacts Channel for Real-time Updates
# Handles WebSocket subscriptions for contact list updates
#
# Streams:
#   - user_#{id}_contacts: User-specific contacts (visibility-based)
#   - contacts_global: Global broadcasts (admin, announcements)
class ContactsChannel < ApplicationCable::Channel
  # Called when client subscribes to this channel
  def subscribed
    # User-specific stream for contacts visible to this user
    stream_from "user_#{current_user.id}_contacts"

    # Global stream for all users (optional, for admin broadcasts)
    stream_from "contacts_global" if current_user.super_admin?

    Rails.logger.info "[ContactsChannel] User #{current_user.id} subscribed"
  end

  # Called when client unsubscribes
  def unsubscribed
    Rails.logger.info "[ContactsChannel] User #{current_user.id} unsubscribed"
  end
end
