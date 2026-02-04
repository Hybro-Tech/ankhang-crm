# frozen_string_literal: true

# TASK-064: Updated for simplified status (4 states)
module ContactsHelper
  def status_badge_color(contact)
    case contact.status
    when "new_contact"
      "bg-blue-100 text-blue-800"
    when "potential"
      "bg-teal-100 text-teal-800"
    when "failed"
      "bg-red-100 text-red-800"
    when "closed"
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  # TASK-052: Helper for contact status color in admin views
  def contact_status_color(status)
    case status.to_s
    when "new_contact"
      "bg-blue-100 text-blue-800"
    when "potential"
      "bg-teal-100 text-teal-800"
    when "failed"
      "bg-red-100 text-red-800"
    when "closed"
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
