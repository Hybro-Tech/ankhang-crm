# frozen_string_literal: true

# TASK-014: Custom Devise Passwords Controller
# Logs password change/reset events to ActivityLog
module Users
  class PasswordsController < Devise::PasswordsController
    # After successfully updating password
    def after_resetting_password_path_for(resource)
      log_password_reset(resource)
      super
    end

    private

    def log_password_reset(user)
      ActivityLog.create!(
        user: user,
        action: "password_reset",
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end
  end
end
