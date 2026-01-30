# frozen_string_literal: true

# TASK-057: Controller for notifications
# Handles notification listing, marking as read
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /notifications
  def index
    authorize! :view, :notifications
    @notifications = current_user.notifications.recent.page(params[:page]).per(20)
    @unread_count = current_user.notifications.unread.count

    # Mark all as seen when viewing full list
    mark_all_as_seen
  end

  # GET /notifications/dropdown (for Turbo Frame lazy loading)
  def dropdown
    @notifications = current_user.notifications.for_dropdown
    @total_count = current_user.notifications.count
    @remaining_count = [@total_count - 10, 0].max

    # Mark all as seen when dropdown opens
    mark_all_as_seen

    render layout: false
  end

  # POST /notifications/:id/mark_as_read
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    # Update badge count in real-time
    broadcast_badge_update

    respond_to do |format|
      format.html { redirect_to notification.action_url || notifications_path }
      format.turbo_stream
      format.json { head :ok }
    end
  end

  # POST /notifications/mark_all_as_read
  def mark_all_as_read
    # rubocop:disable Rails/SkipsModelValidations -- Bulk update for performance
    current_user.notifications.unread.update_all(read: true, read_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations

    # Update badge count in real-time
    broadcast_badge_update

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Đã đánh dấu tất cả đã đọc" }
      format.turbo_stream
      format.json { head :ok }
    end
  end

  # GET /notifications/unread_count (for polling)
  def unread_count
    count = current_user.notifications.unread.count
    render json: { count: count }
  end

  private

  # Mark all unseen notifications as seen and broadcast badge update
  def mark_all_as_seen
    unseen_count = current_user.notifications.unseen.count
    return unless unseen_count.positive?

    # rubocop:disable Rails/SkipsModelValidations -- Bulk update for performance
    current_user.notifications.unseen.update_all(seen: true, seen_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations

    broadcast_badge_update
  end

  # Broadcast badge update to user's notification stream
  def broadcast_badge_update
    unread_count = current_user.notifications.unread.count

    badge_html = if unread_count.positive?
                   display = unread_count > 9 ? "9+" : unread_count.to_s
                   badge_class = "absolute -top-1 -right-1 flex items-center justify-center " \
                                 "h-5 w-5 rounded-full bg-brand-red text-white text-xs font-bold ring-2 ring-white"
                   %(<span id="notification_badge" class="#{badge_class}">#{display}</span>)
                 else
                   %(<span id="notification_badge" class="hidden"></span>)
                 end

    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{current_user.id}_notifications",
      target: "notification_badge",
      html: badge_html
    )
  end
end
