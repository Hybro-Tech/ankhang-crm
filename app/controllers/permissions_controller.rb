# frozen_string_literal: true

# TASK-RBAC: Permissions management controller
# Allows Super Admin to CRUD permissions for role assignment
class PermissionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_permission, only: %i[edit update destroy toggle_active]

  def index
    @permissions = Permission.ordered.group_by(&:category)
  end

  def new
    @permission = Permission.new
    @categories = Permission.distinct.pluck(:category).compact.sort
  end

  def edit
    @categories = Permission.distinct.pluck(:category).compact.sort
  end

  def create
    @permission = Permission.new(permission_params)

    if @permission.save
      redirect_to permissions_path, notice: t(".success")
    else
      @categories = Permission.distinct.pluck(:category).compact.sort
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @permission.update(permission_params)
      redirect_to permissions_path, notice: t(".success")
    else
      @categories = Permission.distinct.pluck(:category).compact.sort
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @permission.roles.any?
      redirect_to permissions_path, alert: t(".in_use_error", count: @permission.roles.count)
    elsif @permission.destroy
      redirect_to permissions_path, notice: t(".success")
    else
      redirect_to permissions_path, alert: @permission.errors.full_messages.join(", ")
    end
  end

  def toggle_active
    @permission.update(active: !@permission.active)
    status = @permission.active? ? "kích hoạt" : "tắt"
    redirect_to permissions_path, notice: "Permission đã được #{status}."
  end

  private

  def set_permission
    @permission = Permission.find(params[:id])
  end

  def permission_params
    params.expect(permission: %i[code name category description active])
  end
end
