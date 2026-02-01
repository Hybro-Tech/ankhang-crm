# frozen_string_literal: true

# TASK-LOGGING: Helper methods for logs views
module Admin
  module LogsHelper
    # Badge class for action type
    def action_badge_class(action)
      case action.to_s
      when /create/
        "bg-green-100 text-green-800"
      when /update/
        "bg-yellow-100 text-yellow-800"
      when /destroy/, /delete/
        "bg-red-100 text-red-800"
      when /login/
        "bg-blue-100 text-blue-800"
      when /logout/
        "bg-gray-100 text-gray-800"
      else
        "bg-gray-100 text-gray-700"
      end
    end

    # Badge class for event type
    def event_type_class(event_type)
      case event_type.to_s
      when "page_view"
        "bg-blue-100 text-blue-800"
      when "form_submit"
        "bg-green-100 text-green-800"
      when "ajax"
        "bg-purple-100 text-purple-800"
      when "api_call"
        "bg-yellow-100 text-yellow-800"
      when "download"
        "bg-orange-100 text-orange-800"
      else
        "bg-gray-100 text-gray-700"
      end
    end

    # Badge class for HTTP method
    def method_class(method)
      case method.to_s.upcase
      when "GET"
        "bg-blue-100 text-blue-800"
      when "POST"
        "bg-green-100 text-green-800"
      when "PUT", "PATCH"
        "bg-yellow-100 text-yellow-800"
      when "DELETE"
        "bg-red-100 text-red-800"
      else
        "bg-gray-100 text-gray-700"
      end
    end

    # Badge class for HTTP status
    def status_class(status)
      case status.to_i
      when 200..299
        "bg-green-100 text-green-800"
      when 300..399
        "bg-blue-100 text-blue-800"
      when 400..499
        "bg-yellow-100 text-yellow-800"
      when 500..599
        "bg-red-100 text-red-800"
      else
        "bg-gray-100 text-gray-700"
      end
    end
  end
end
