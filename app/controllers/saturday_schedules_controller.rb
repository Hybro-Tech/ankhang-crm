# frozen_string_literal: true

class SaturdaySchedulesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @saturday_schedules = SaturdaySchedule.upcoming.page(params[:page]).per(params[:per_page] || 10)
    @past_schedules = SaturdaySchedule.past.limit(5)
  end

  def show; end

  def new
    @saturday_schedule = SaturdaySchedule.new
    @teams = Team.includes(:users).all
  end

  def edit
    @teams = Team.includes(:users).all
  end

  def create
    @saturday_schedule = SaturdaySchedule.new(saturday_schedule_params)

    if @saturday_schedule.save
      redirect_to saturday_schedules_path, notice: "Lịch làm việc Thứ 7 đã được tạo thành công."
    else
      @teams = Team.includes(:users).all
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @saturday_schedule.update(saturday_schedule_params)
      redirect_to saturday_schedules_path, notice: "Lịch làm việc cập nhật thành công."
    else
      @teams = Team.includes(:users).all
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @saturday_schedule.destroy
    redirect_to saturday_schedules_path, notice: "Đã xóa lịch làm việc."
  end

  private

  def saturday_schedule_params
    params.expect(saturday_schedule: [:date, :description, { user_ids: [] }])
  end
end
