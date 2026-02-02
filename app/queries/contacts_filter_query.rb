# frozen_string_literal: true

# Query Object for filtering contacts with complex conditions
# Encapsulates the filtering logic from ContactsController
class ContactsFilterQuery
  def initialize(scope, filters = {})
    @scope = scope
    @filters = filters
  end

  def call
    filter_by_status
    filter_by_source
    filter_by_service_type
    filter_by_team
    filter_by_assigned_user
    filter_by_date_range
    filter_by_search
    @scope
  end

  private

  def filter_by_status
    return if @filters[:status].blank?

    @scope = @scope.where(status: @filters[:status])
  end

  def filter_by_source
    return if @filters[:source_id].blank?

    @scope = @scope.where(source_id: @filters[:source_id])
  end

  def filter_by_service_type
    return if @filters[:service_type_id].blank?

    @scope = @scope.where(service_type_id: @filters[:service_type_id])
  end

  def filter_by_team
    return if @filters[:team_id].blank?

    @scope = @scope.where(team_id: @filters[:team_id])
  end

  def filter_by_assigned_user
    return if @filters[:assigned_user_id].blank?

    @scope = if @filters[:assigned_user_id] == "unassigned"
               @scope.where(assigned_user_id: nil)
             else
               @scope.where(assigned_user_id: @filters[:assigned_user_id])
             end
  end

  def filter_by_date_range
    filter_by_start_date
    filter_by_end_date
  end

  def filter_by_start_date
    return if @filters[:start_date].blank?

    @scope = @scope.where(created_at: Date.parse(@filters[:start_date]).beginning_of_day..)
  end

  def filter_by_end_date
    return if @filters[:end_date].blank?

    @scope = @scope.where(created_at: ..Date.parse(@filters[:end_date]).end_of_day)
  end

  def filter_by_search
    return if @filters[:q].blank?

    search_term = "%#{@filters[:q]}%"
    @scope = @scope.where(
      "name LIKE :q OR phone LIKE :q OR code LIKE :q OR email LIKE :q",
      q: search_term
    )
  end
end
