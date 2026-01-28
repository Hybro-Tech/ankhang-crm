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
                     "bg-white text-[#0B387A] rounded-lg shadow-md font-bold"
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

  # Sidebar section header helper
  # Shows section header only if user has permission to view at least one item
  # @param title [String] Section title
  # @param permissions [Array<String>] List of permission codes for items in section
  def sidebar_section(title, permissions = [])
    # Super admin sees all sections
    return render_section_header(title) if current_user&.super_admin?

    # Check if user has at least one permission in the list
    has_any_permission = permissions.any? { |perm| can_access?(perm) }
    return nil unless has_any_permission

    render_section_header(title)
  end

  private

  def render_section_header(title)
    content_tag(:div, title, class: "pt-6 pb-2 px-4 text-xs font-bold text-blue-300 uppercase tracking-wider")
  end

  # Concise time formatter for lists
  # Today: "14:30"
  # This year: "28/01 08:30"
  # Old: "28/01/25"
  def format_short_time(datetime)
    return "" unless datetime

    now = Time.current
    if datetime.to_date == now.to_date
      "Hôm nay #{datetime.strftime('%H:%M')}"
    elsif datetime.year == now.year
      datetime.strftime("%d/%m")
    else
      datetime.strftime("%d/%m/%y")
    end
  end
end
