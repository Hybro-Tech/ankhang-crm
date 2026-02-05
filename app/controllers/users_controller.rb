# frozen_string_literal: true

# TASK-017: Users CRUD controller
# Manages employee accounts, roles assignment, and account status
# TASK-070: Added per-user service type limit configuration (dynamic nested form)
class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :load_service_types, only: %i[new edit create update]

  def index
    @users = User.accessible_by(current_ability).includes(:roles, :teams)

    # Filter by Team
    @users = @users.joins(:team_members).where(team_members: { team_id: params[:team_id] }) if params[:team_id].present?

    # Filter by Status
    @users = @users.where(status: params[:status]) if params[:status].present?

    @users = @users.page(params[:page]).per(params[:per_page])
  end

  def new
    @user.status = "active" # Default status
  end

  def edit; end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "Tạo nhân viên thành công."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if user_params[:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to users_path, notice: "Cập nhật nhân viên thành công."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "Bạn không thể xóa chính mình."
    elsif @user.destroy
      redirect_to users_path, notice: "Xóa nhân viên thành công."
    else
      redirect_to users_path, alert: "Không thể xóa nhân viên này."
    end
  end

  private

  def load_service_types
    @service_types = ServiceType.active.ordered
  end

  # rubocop:disable Rails/StrongParametersExpect -- params.expect doesn't work with nested attributes
  def user_params
    params.require(:user).permit(
      :name, :email, :username, :password, :password_confirmation, :status,
      :phone, :region_id, :address,
      role_ids: [], team_ids: [],
      user_service_type_limits_attributes: %i[id service_type_id max_pick_per_day _destroy]
    )
  end
  # rubocop:enable Rails/StrongParametersExpect
end
