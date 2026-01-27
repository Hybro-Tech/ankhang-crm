# frozen_string_literal: true

module ApplicationHelper
  # Sidebar link helper
  # @param permission [String, nil] Permission code like 'contacts.view'
  #   If provided, link is hidden when user lacks permission
  def sidebar_link(title, path, icon, permission: nil, is_active: false)
    # TASK-015: Skip rendering if permission required but not granted
    return nil if permission.present? && !can_access?(permission)

    # Check active state:
    # 1. Explicitly active
    # 2. Exact match (current_page?)
    # 3. Sub-path match (e.g. /contacts/new starts with /contacts/), ignoring root to avoid all-match
    active = is_active || 
             current_page?(path) || 
             (path.to_s != root_path.to_s && request.path.start_with?("#{path}/"))

    active_class = if active
                     "bg-white text-brand-blue rounded-lg shadow-md font-bold"
                   else
                     "text-blue-100 hover:text-white hover:bg-blue-800 rounded-lg transition-colors font-medium"
                   end

    icon_class = if active
                   "text-brand-orange"
                 else
                   "text-blue-300 group-hover:text-white transition-colors"
                 end

    link_to path, class: "flex items-center px-4 py-2.5 group #{active_class}" do
      content_tag(:i, nil, class: "fa-solid #{icon} w-6 #{icon_class}") +
        content_tag(:span, title)
    end
  end

  # Page title helper
  def page_title(title)
    content_for(:title) { "#{title} - AnKhangCRM" }
    content_for(:page_title) { title }
  end

  # Breadcrumb helper
  def breadcrumb(&)
    content_for(:breadcrumb, &)
  end
end
