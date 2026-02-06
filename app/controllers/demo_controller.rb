# frozen_string_literal: true

# Demo controller for testing base UI layout
# SECURITY-AUDIT: Restricted to development or Super Admin
class DemoController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_to_dev_or_admin
  skip_authorization_check

  # Demo page to showcase base UI components
  def index
    flash.now[:notice] = I18n.t("demo.success") if params[:flash] == "success"
    flash.now[:alert] = I18n.t("demo.error") if params[:flash] == "error"
    flash.now[:warning] = I18n.t("demo.warning") if params[:flash] == "warning"
  end

  private

  def restrict_to_dev_or_admin
    return if Rails.env.local? || current_user.super_admin?

    redirect_to root_path, alert: "Demo page is not available"
  end
end
