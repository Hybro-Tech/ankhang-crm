# frozen_string_literal: true

# TASK-017: Users CRUD controller
# Manages employee accounts, roles assignment, and account status
class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.accessible_by(current_ability).includes(:roles, :teams)

    # Filter by Team
    if params[:team_id].present?
      @users = @users.joins(:team_members).where(team_members: { team_id: params[:team_id] })
    end

    # Filter by Status
    if params[:status].present?
      @users = @users.where(status: params[:status])
    end

    @users = @users.page(params[:page]).per(params[:per_page])
  end

  def new
    @user.status = "active" # Default status
  end

  def edit; end

  def create
    @user = User.new(user_params)

    # Set default password if not provided for new users (optional strategy, but for now we require it)

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

  def user_params
    params.expect(user: [:name, :email, :username, :password, :password_confirmation, :status,
                         { role_ids: [], team_ids: [] }])
  end
end
