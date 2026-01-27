# frozen_string_literal: true

# TASK-016: Roles management controller
# Provides CRUD operations for roles with permission matrix
class RolesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @roles = Role.includes(:users)
                 .order(:name)
                 .page(params[:page])
                 .per(params[:per_page])
  end

  def show
    redirect_to edit_role_path(@role)
  end

  def new
    @role = Role.new
    @permissions = Permission.grouped_by_category
  end

  def edit
    @permissions = Permission.grouped_by_category
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      update_permissions
      redirect_to roles_path, notice: t(".success")
    else
      @permissions = Permission.grouped_by_category
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @role.is_system? && role_params[:name] != @role.name
      redirect_to roles_path, alert: t(".system_role_error")
      return
    end

    if @role.update(role_params)
      update_permissions
      redirect_to roles_path, notice: t(".success")
    else
      @permissions = Permission.grouped_by_category
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @role.is_system?
      redirect_to roles_path, alert: t(".system_role_error")
    elsif @role.destroy
      redirect_to roles_path, notice: t(".success")
    else
      redirect_to roles_path, alert: @role.errors.full_messages.join(", ")
    end
  end

  def clone
    new_name = "#{@role.name} (Copy)"
    new_role = @role.clone_with_permissions(new_name)

    if new_role.persisted?
      redirect_to edit_role_path(new_role), notice: t(".success")
    else
      redirect_to roles_path, alert: new_role.errors.full_messages.join(", ")
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.expect(role: %i[name description dashboard_type])
  end

  def update_permissions
    permission_ids = params[:role][:permission_ids]&.reject(&:blank?)&.map(&:to_i) || []
    @role.permission_ids = permission_ids
  end
end
