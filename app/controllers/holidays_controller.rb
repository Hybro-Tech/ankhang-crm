# frozen_string_literal: true

class HolidaysController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    set_available_years
    set_selected_year
    set_holidays
    set_stats
  end

  def new; end

  def edit; end

  def create
    if @holiday.save
      redirect_to holidays_path(year: @holiday.date.year), notice: "Tạo ngày nghỉ lễ thành công."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @holiday.update(holiday_params)
      redirect_to holidays_path(year: @holiday.date.year), notice: "Cập nhật ngày nghỉ lễ thành công."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    year = @holiday.date.year
    @holiday.destroy
    redirect_to holidays_path(year: year), notice: "Đã xóa ngày nghỉ lễ."
  end

  private

  def set_available_years
    @available_years = Holiday.distinct.pluck(Arel.sql("YEAR(date)")).compact.sort.reverse
    @available_years = [Date.current.year] if @available_years.empty?
  end

  def set_selected_year
    @selected_year = params[:year].present? ? params[:year].to_i : @available_years.first
  end

  def set_holidays
    base = Holiday.where("YEAR(date) = ?", @selected_year).order(date: :asc)
    @selected_month = params[:month].presence&.to_i

    @holidays = if @selected_month.present? && @selected_month.between?(1, 12)
                  base.where("MONTH(date) = ?", @selected_month)
                else
                  base
                end.page(params[:page]).per(params[:per_page] || 10)
  end

  def set_stats
    base = Holiday.where("YEAR(date) = ?", @selected_year)
    @total_holidays = base.count
    @holidays_by_month = base.group_by { |h| h.date.month }
  end

  def holiday_params
    params.expect(holiday: %i[name date description])
  end
end
