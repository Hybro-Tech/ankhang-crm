# frozen_string_literal: true

# TASK-LOGGING: Custom Devise Failure App to log failed login attempts
class CustomFailureApp < Devise::FailureApp
  FAILURE_REASONS = {
    invalid: "invalid_password",
    not_found_in_database: "user_not_found",
    locked: "account_locked"
  }.freeze

  def respond
    log_failed_login
    super
  end

  private

  def log_failed_login
    return unless scope == :user

    user = find_attempted_user
    create_failed_login_log(user)
  rescue StandardError => e
    Rails.logger.error("[CustomFailureApp] Failed to log login failure: #{e.message}")
  end

  def find_attempted_user
    login = attempted_login_identifier
    User.find_by(email: login) || User.find_by(username: login)
  end

  def attempted_login_identifier
    params.dig(:user, :login) || params.dig(:user, :email) || "unknown"
  end

  def create_failed_login_log(user)
    ActivityLog.create!(
      user: user,
      user_name: user&.name || attempted_login_identifier,
      action: "login_failed",
      category: "authentication",
      subject: user,
      details: build_failure_details(user),
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  def build_failure_details(user)
    {
      attempted_login: attempted_login_identifier,
      reason: determine_failure_reason(user),
      warden_message: warden_message.to_s
    }
  end

  def determine_failure_reason(user)
    return "user_not_found" if user.nil?
    return "account_locked" if user.access_locked?
    return "account_inactive" if inactive_user?(user)

    FAILURE_REASONS[warden_message] || "authentication_failed"
  end

  def inactive_user?(user)
    user.respond_to?(:active?) && !user.active?
  end
end
