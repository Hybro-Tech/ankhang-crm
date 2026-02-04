# frozen_string_literal: true

# TASK-068: Admin management of provinces (63 Vietnamese provinces)
class ProvincesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_province, only: %i[show edit update destroy toggle_active]
  authorize_resource

  def index
    @provinces = Province.includes(:regions).ordered.page(params[:page]).per(params[:per_page] || 20)

    # Optional filtering
    @provinces = @provinces.where(active: true) if params[:active] == "true"
    @provinces = @provinces.where(active: false) if params[:active] == "false"
  end

  def show; end

  def new
    @province = Province.new(position: Province.maximum(:position).to_i + 1)
  end

  def edit; end

  def create
    @province = Province.new(province_params)

    if @province.save
      redirect_to provinces_path, notice: t("provinces.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @province.update(province_params)
      redirect_to provinces_path, notice: t("provinces.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @province.contacts.exists?
      redirect_to provinces_path, alert: t("provinces.cannot_delete")
    else
      @province.destroy
      redirect_to provinces_path, notice: t("provinces.deleted")
    end
  end

  # PATCH /provinces/:id/toggle_active
  def toggle_active
    @province.update(active: !@province.active)
    redirect_to provinces_path, notice: t("provinces.status_updated")
  end

  private

  def set_province
    @province = Province.find(params[:id])
  end

  def province_params
    params.expect(province: %i[name code position active region_ids])
  end
end
