# frozen_string_literal: true

module ContactsHelper
  def status_badge_color(contact)
    case contact.status
    when "new_contact"
      "bg-blue-100 text-blue-800"
    when "potential", "potential_old"
      "bg-yellow-100 text-yellow-800"
    when "in_progress"
      "bg-purple-100 text-purple-800"
    when "closed_new", "closed_old"
      "bg-green-100 text-green-800"
    when "cskh_l1", "cskh_l2"
      "bg-pink-100 text-pink-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  # TASK-052: Helper for contact status color in admin views
  def contact_status_color(status)
    case status.to_s
    when "new_contact"
      "bg-blue-100 text-blue-800"
    when "potential", "potential_old"
      "bg-amber-100 text-amber-800"
    when "in_progress"
      "bg-purple-100 text-purple-800"
    when "closed_new", "closed_old"
      "bg-green-100 text-green-800"
    when "cskh_l1", "cskh_l2"
      "bg-pink-100 text-pink-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
