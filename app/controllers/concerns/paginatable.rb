# frozen_string_literal: true

# Concern for pagination support in controllers
# Usage: include Paginatable
# Then use: paginate(Model.all) or @items = paginate(Model.where(...))
module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 100
  ALLOWED_PER_PAGE = [10, 25, 50, 100].freeze

  included do
    helper_method :per_page if respond_to?(:helper_method)
  end

  private

  def paginate(scope)
    scope.page(current_page).per(per_page)
  end

  def current_page
    (params[:page] || 1).to_i
  end

  def per_page
    requested = (params[:per_page] || DEFAULT_PER_PAGE).to_i
    ALLOWED_PER_PAGE.include?(requested) ? requested : DEFAULT_PER_PAGE
  end
end
