# frozen_string_literal: true

# Shared helper for rendering notification badge HTML
# Used by Turbo Streams broadcasts from services and models
module NotificationBadgeHelper
  extend ActiveSupport::Concern

  # Render notification badge HTML for Turbo Stream broadcasts
  # @param count [Integer] Number of unread notifications
  # @return [String] HTML string for the badge
  def notification_badge_html(count)
    if count.positive?
      display = count > 9 ? "9+" : count.to_s
      %(<span id="notification_badge" class="absolute -top-1 -right-1 flex items-center ) +
        %(justify-center h-5 w-5 rounded-full bg-brand-red text-white text-xs font-bold ) +
        %(ring-2 ring-white">#{display}</span>)
    else
      %(<span id="notification_badge" class="hidden"></span>)
    end
  end

  # Render KPI count badge HTML for Turbo Stream broadcasts
  # @param count [Integer] Number of new contacts
  # @return [String] HTML string for the KPI badge
  # rubocop:disable Layout/LineLength
  def kpi_badge_html(count)
    %(<span id="kpi_new_contacts" class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-blue-100 text-brand-blue font-bold">#{count}</span>)
  end
  # rubocop:enable Layout/LineLength
end
