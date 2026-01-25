class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.accessible_by(current_ability).includes(:roles, :team)
  end

  def new
    @user.status = "active" # Default status
  end

  def create
    @user = User.new(user_params)
    # Set default password if not provided for new users (optional strategy, but for now we require it)
    
    if @user.save
      redirect_to users_path, notice: "Tạo nhân viên thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if user_params[:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to users_path, notice: "Cập nhật nhân viên thành công."
    else
      render :edit, status: :unprocessable_entity
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
    params.require(:user).permit(:name, :email, :username, :password, :password_confirmation, :team_id, :status, role_ids: [])
  end
end
