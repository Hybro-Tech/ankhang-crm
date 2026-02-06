# frozen_string_literal: true

# TASK-PROFILE: User profile management
# Allows users to view/edit personal info, change password, and view activity history
# SECURITY-AUDIT: Personal profile - accessible to all authenticated users
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check # Personal profile - accessible to all authenticated users
  before_action :set_user

  # GET /profile
  def show
    @page = (params[:page] || 1).to_i
    @per_page = 10
    @recent_events = user_activity_history
    @total_events = UserEvent.where(user_id: current_user.id).count
    @total_pages = (@total_events.to_f / @per_page).ceil
  end

  # PATCH /profile
  def update
    if @user.update(profile_params)
      flash[:notice] = t(".success")
      redirect_to profile_path
    else
      render_show_with_error(t(".error"))
    end
  end

  # PATCH /profile/password
  def update_password
    error = validate_password_change
    return render_show_with_error(error) if error

    if @user.update(password: params[:password])
      bypass_sign_in(@user) # Re-sign in to prevent logout
      flash[:notice] = t("profiles.password.success")
      redirect_to profile_path
    else
      render_show_with_error(t("profiles.password.error"))
    end
  end

  # DELETE /profile/avatar
  def destroy_avatar
    @user.avatar.purge if @user.avatar.attached?
    flash[:notice] = t("profiles.avatar.removed")
    redirect_to profile_path
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.expect(user: %i[name phone email avatar region_id address])
  end

  def user_activity_history
    offset = (@page - 1) * @per_page
    UserEvent.where(user_id: current_user.id).recent.offset(offset).limit(@per_page)
  end

  def render_show_with_error(message)
    @page = 1
    @per_page = 10
    @recent_events = user_activity_history
    @total_events = UserEvent.where(user_id: current_user.id).count
    @total_pages = (@total_events.to_f / @per_page).ceil
    flash.now[:alert] = message
    render :show, status: :unprocessable_content
  end

  def validate_password_change
    return t("profiles.password.current_invalid") unless @user.valid_password?(params[:current_password])
    return t("profiles.password.confirmation_mismatch") if params[:password] != params[:password_confirmation]
    return t("profiles.password.too_short") if params[:password].to_s.length < 6

    nil
  end
end
