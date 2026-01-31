# frozen_string_literal: true

# TASK: Solid Cable Monitoring Dashboard
# Custom dashboard for monitoring Solid Cable WebSocket messages
module Admin
  class SolidCableController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_super_admin!

    def show
      @stats = build_stats
      @channels = fetch_channels
      @messages_by_hour = fetch_messages_by_hour
    end

    def cleanup
      deleted_count = cable_messages.where(created_at: ..1.day.ago).delete_all
      flash[:success] = "Đã xóa #{deleted_count} tin nhắn cũ"
      redirect_to admin_solid_cable_path
    end

    private

    def authorize_super_admin!
      authorize! :manage, :solid_cable
    end

    def cable_messages
      @cable_messages ||= SolidCable::Message.all
    end

    def build_stats
      {
        total_messages: cable_messages.count,
        oldest_message: cable_messages.minimum(:created_at),
        newest_message: cable_messages.maximum(:created_at),
        channels_count: cable_messages.distinct.count(:channel),
        messages_last_hour: cable_messages.where(created_at: 1.hour.ago..).count,
        messages_last_24h: cable_messages.where(created_at: 24.hours.ago..).count
      }
    end

    def fetch_channels
      cable_messages
        .group(:channel)
        .select(:channel, "COUNT(*) as message_count", "MAX(created_at) as last_activity")
        .order(message_count: :desc)
        .limit(20)
    end

    def fetch_messages_by_hour
      return {} unless defined?(Groupdate)

      cable_messages
        .where(created_at: 24.hours.ago..)
        .group_by_hour(:created_at)
        .count
    end
  end
end
