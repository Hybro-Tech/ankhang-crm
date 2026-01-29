# frozen_string_literal: true

# TASK-019: Service Types Controller
# Manages service types (Loại nhu cầu) - Admin only
class ServiceTypesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service_type, only: %i[show edit update destroy]
  before_action :authorize_admin!

  def index
    @service_types = ServiceType.includes(:team)
                                .ordered
                                .page(params[:page])
                                .per(params[:per_page] || 10)
  end

  def show; end

  def new
    @service_type = ServiceType.new
    @teams = Team.all
  end

  def edit
    @teams = Team.all
  end

  def create
    @service_type = ServiceType.new(service_type_params)

    if @service_type.save
      redirect_to service_types_path, notice: t(".success")
    else
      @teams = Team.all
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @service_type.update(service_type_params)
      redirect_to service_types_path, notice: t(".success")
    else
      @teams = Team.all
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @service_type.contacts.any?
      redirect_to service_types_path, alert: t(".has_contacts")
    else
      @service_type.destroy
      redirect_to service_types_path, notice: t(".success")
    end
  end

  private

  def set_service_type
    @service_type = ServiceType.find(params[:id])
  end

  def authorize_admin!
    authorize! :manage, :settings
  end

  def service_type_params
    params.expect(service_type: %i[name description team_id active position max_pick_per_day pick_cooldown_minutes
                                   visibility_expand_minutes])
  end
end
