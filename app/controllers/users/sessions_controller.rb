# frozen_string_literal: true

# TASK-014: Custom Devise Sessions Controller
# Logs authentication events to ActivityLog
class Users::SessionsController < Devise::SessionsController
  after_action :log_login, only: :create
  after_action :log_logout, only: :destroy

  private

  def log_login
    return unless current_user

    ActivityLog.create!(
      user: current_user,
      action: "login",
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      details: { method: "password" }
    )
  end

  def log_logout
    # current_user is nil after sign_out, so we use warden.user(:user)
    # But Devise clears this too, so we need to get user before calling super
    # This is handled by storing user_id before destroy via prepend_before_action
    user_id = session[:logged_out_user_id]
    return unless user_id

    ActivityLog.create!(
      user_id: user_id,
      action: "logout",
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  # Store user ID before logout for logging
  prepend_before_action :store_user_for_logout, only: :destroy

  def store_user_for_logout
    session[:logged_out_user_id] = current_user&.id
  end
end
