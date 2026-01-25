# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # TASK-012: Use separate layout for Devise auth pages
  layout :layout_by_resource

  protected

  def configure_permitted_parameters
    # TASK-011: Allow username for registration
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name username phone])
  end

  private

  def layout_by_resource
    if devise_controller?
      'devise'
    else
      'application'
    end
  end
end
