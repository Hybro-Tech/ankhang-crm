# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # TASK-015: CanCanCan authorization
  include CanCan::ControllerAdditions

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_attributes

  # TASK-012: Use separate layout for Devise auth pages
  layout :layout_by_resource

  # TASK-015: Handle authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        flash[:alert] = "Bạn không có quyền thực hiện thao tác này."
        redirect_to(request.referer || root_path)
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("flash",
                                                 partial: "shared/flash_messages",
                                                 locals: { alert: "Bạn không có quyền thực hiện thao tác này." })
      end
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  protected

  def configure_permitted_parameters
    # TASK-011: Allow username for registration
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[login password remember_me])
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name username email password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[name username phone email password password_confirmation
                                               current_password])
  end

  def after_sign_in_path_for(resource)
    if can?(:view_sales, :dashboards)
      sales_workspace_path
    elsif can?(:view_call_center, :dashboards)
      # TASK-049: Redirect Call Center staff to their dashboard
      dashboard_call_center_path
    elsif can?(:show, :cskh_workspace)
      # CSKH Workspace: Default landing for CSKH role
      cskh_workspace_path
    else
      super
    end
  end

  private

  # TASK-PERF: Preload associations needed by Ability class for fast permission checks
  # This ensures Ability.new takes <50ms instead of 700ms+
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = warden.authenticate(scope: :user)
    return nil unless @current_user

    # Preload associations if not already loaded
    unless @current_user.roles.loaded?
      ActiveRecord::Associations::Preloader.new(
        records: [@current_user],
        associations: [{ roles: :permissions }, { user_permissions: :permission }, :managed_team]
      ).call
    end

    @current_user
  end

  # TASK-LOGGING: Set Current attributes for use by Loggable concern
  def set_current_attributes
    Current.user = current_user if user_signed_in?
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
    Current.request_id = request.request_id
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
