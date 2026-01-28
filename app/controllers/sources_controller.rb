# frozen_string_literal: true

# Sources Controller
# Manages contact sources (Nguồn khách hàng) - RBAC protected
class SourcesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @sources = @sources.ordered
                       .page(params[:page])
                       .per(params[:per_page] || 10)
  end

  def show; end

  def new
    # @source initialized by load_resource
  end

  def edit; end

  def create
    # @source initialized by load_resource with params
    if @source.save
      redirect_to sources_path, notice: t(".success")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @source.update(source_params)
      redirect_to sources_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @source.contacts.any?
      redirect_to sources_path, alert: t(".has_contacts")
    else
      @source.destroy
      redirect_to sources_path, notice: t(".success")
    end
  end

  private

  def source_params
    params.expect(source: %i[name description active position])
  end
end
