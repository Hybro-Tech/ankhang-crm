# frozen_string_literal: true
require 'ostruct'

class ApplicationController < ActionController::Base
  # Mock Devise helpers until configured (TASK-006)
  helper_method :user_signed_in?, :current_user

  def user_signed_in?
    # Return true to test authenticated layout, false for guest
    params[:auth] != "false"
  end

  def current_user
    # Mock user object
    OpenStruct.new(email: "admin@ankhang.com")
  end
end
