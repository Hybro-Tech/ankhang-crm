# frozen_string_literal: true

# TASK-035: Notifications Channel for Real-time Badge Updates
# Handles WebSocket subscriptions for notification badge updates
class NotificationsChannel < ApplicationCable::Channel
  # Called when client subscribes to this channel
  def subscribed
    # User-specific stream for notifications
    stream_from "user_#{current_user.id}_notifications"

    Rails.logger.info "[NotificationsChannel] User #{current_user.id} subscribed"
  end

  # Called when client unsubscribes
  def unsubscribed
    Rails.logger.info "[NotificationsChannel] User #{current_user.id} unsubscribed"
  end
end
