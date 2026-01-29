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
  end

  # GET /notifications/dropdown (for AJAX)
  def dropdown
    @notifications = current_user.notifications.for_dropdown
    @unread_count = current_user.notifications.unread.count

    # Mark all as seen when dropdown opens
    # rubocop:disable Rails/SkipsModelValidations -- Bulk update for performance
    current_user.notifications.unseen.update_all(seen: true, seen_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations

    render partial: "notifications/dropdown", locals: {
      notifications: @notifications,
      unread_count: @unread_count
    }
  end

  # POST /notifications/:id/mark_as_read
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

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
end
