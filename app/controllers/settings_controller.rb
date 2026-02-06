# frozen_string_literal: true

# User personal settings controller
# Allows all authenticated users to manage their notification preferences
# No CanCanCan authorization needed - personal settings available to everyone
class SettingsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check # Personal settings - no role-specific restriction

  # GET /settings
  def show
    # View will use push_subscription Stimulus controller for Web Push toggle
  end
end
