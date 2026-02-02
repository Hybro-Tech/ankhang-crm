# frozen_string_literal: true

# TASK-REGION: Admin management of regions
class RegionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_region, only: %i[show edit update destroy toggle_active]
  authorize_resource

  def index
    @regions = Region.ordered.page(params[:page]).per(params[:per_page] || 10)
  end

  def show; end

  def new
    @region = Region.new(position: Region.maximum(:position).to_i + 1)
  end

  def edit; end

  def create
    @region = Region.new(region_params)

    if @region.save
      redirect_to regions_path, notice: t("regions.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @region.update(region_params)
      redirect_to regions_path, notice: t("regions.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @region.users.exists? || @region.teams.exists?
      redirect_to regions_path, alert: t("regions.cannot_delete")
    else
      @region.destroy
      redirect_to regions_path, notice: t("regions.deleted")
    end
  end

  # PATCH /regions/:id/toggle_active
  def toggle_active
    @region.update(active: !@region.active)
    redirect_to regions_path, notice: t("regions.status_updated")
  end

  private

  def set_region
    @region = Region.find(params[:id])
  end

  def region_params
    params.expect(region: %i[name code description position active])
  end
end
