# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @teams = Team.includes(:manager, :users).all
  end

  def show; end

  def new
    @team = Team.new
    load_form_data
  end

  def edit
    load_form_data
  end

  def create
    @team = Team.new(team_params)
    @team.created_at = Time.current
    @team.updated_at = Time.current

    if @team.save
      redirect_to teams_path, notice: "Tạo đội nhóm thành công."
    else
      load_form_data
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @team.update(team_params)
      redirect_to teams_path, notice: "Cập nhật đội nhóm thành công."
    else
      load_form_data
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @team.users.any?
      redirect_to teams_path, alert: "Không thể xóa đội nhóm đang có thành viên."
    else
      @team.destroy
      redirect_to teams_path, notice: "Đã xóa đội nhóm."
    end
  end

  private

  def team_params
    params.expect(team: [:name, :description, :region, :manager_id, { user_ids: [] }])
  end

  def load_form_data
    @managers = User.where(status: :active).order(:name)
    # For M-N, any user can be added. We list all active users.
    @available_users = User.where(status: :active).order(:name)
  end
end
