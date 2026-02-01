# frozen_string_literal: true

# TASK-014: Custom Devise Sessions Controller
# Authentication logging is handled by Warden hooks (config/initializers/warden_hooks.rb)
module Users
  class SessionsController < Devise::SessionsController
    # Store user ID before logout for logging
    prepend_before_action :store_user_for_logout, only: :destroy

    private

    def store_user_for_logout
      session[:logged_out_user_id] = current_user&.id
    end
  end
end
