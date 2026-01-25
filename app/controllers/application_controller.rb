# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # TASK-015: CanCanCan authorization
  include CanCan::ControllerAdditions

  before_action :configure_permitted_parameters, if: :devise_controller?

  # TASK-012: Use separate layout for Devise auth pages
  layout :layout_by_resource

  # TASK-015: Handle authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        flash[:alert] = 'Bạn không có quyền thực hiện thao tác này.'
        redirect_to(request.referer || root_path)
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('flash',
                                                 partial: 'shared/flash_messages',
                                                 locals: { alert: 'Bạn không có quyền thực hiện thao tác này.' })
      end
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  protected

  def configure_permitted_parameters
    # TASK-011: Allow username for registration
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password, :remember_me])
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name username email password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name username phone email password password_confirmation current_password])
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
