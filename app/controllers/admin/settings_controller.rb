# frozen_string_literal: true

# TASK-053: Admin Settings Controller
# Manages system-wide settings for Smart Routing and other configs
module Admin
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @settings = Setting::DEFAULTS.keys.map do |key|
        {
          key: key,
          value: Setting.get(key, Setting::DEFAULTS[key][:value]),
          description: Setting::DEFAULTS[key][:description]
        }
      end
    end

    def update
      settings_params.each do |key, value|
        Setting.set(key, value) if Setting::DEFAULTS.key?(key)
      end

      flash[:success] = "Cài đặt đã được cập nhật thành công"
      redirect_to admin_settings_path
    end

    private

    def authorize_admin!
      authorize! :manage, :settings
    end

    def settings_params
      params.expect(settings: [*Setting::DEFAULTS.keys])
    end
  end
end
