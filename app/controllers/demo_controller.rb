# frozen_string_literal: true

# Demo controller for testing base UI layout
class DemoController < ApplicationController
  # Demo page to showcase base UI components
  def index
    flash.now[:notice] = I18n.t("demo.success") if params[:flash] == "success"
    flash.now[:alert] = I18n.t("demo.error") if params[:flash] == "error"
    flash.now[:warning] = I18n.t("demo.warning") if params[:flash] == "warning"
  end
end
