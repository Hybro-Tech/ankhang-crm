# frozen_string_literal: true

module ApplicationHelper
  # Sidebar link helper
  # @param permission [String, nil] Permission code like 'contacts.view'
  #   If provided, link is hidden when user lacks permission
  # Paths that have dedicated sub-menu items (should NOT activate parent)
  EXCLUDED_SUB_PATHS = {
    "/teams" => ["/teams/reassign_requests"]
  }.freeze

  def sidebar_link(title, path, icon, permission: nil, is_active: false)
    return nil if skip_sidebar_link?(permission)

    active = sidebar_link_active?(path, is_active)

    link_to path, class: "flex items-center px-4 py-2.5 group #{sidebar_link_class(active)}" do
      content_tag(:i, nil, class: "fa-solid #{icon} w-6 #{sidebar_icon_class(active)}") +
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

  # Check if request_path is an excluded sub-path for the given parent_path
  # Used to prevent parent menu from being active when a sub-menu has its own dedicated item
  def excluded_sub_path?(parent_path, request_path)
    excluded_paths = EXCLUDED_SUB_PATHS[parent_path] || []
    excluded_paths.any? { |excluded| request_path.start_with?(excluded) }
  end

  # TASK-015: Skip rendering if permission required but not granted
  # Super admin bypasses permission check
  def skip_sidebar_link?(permission)
    permission.present? && !current_user&.super_admin? && !can_access?(permission)
  end

  # Check active state for sidebar link
  # Active when: explicitly set, exact match, or sub-path match (excluding dedicated sub-menus)
  def sidebar_link_active?(path, is_active)
    return true if is_active || current_page?(path)
    return false if path.to_s == root_path.to_s

    request.path.start_with?("#{path}/") && !excluded_sub_path?(path.to_s, request.path)
  end

  def sidebar_link_class(active)
    if active
      "bg-white text-[#0B387A] rounded-lg shadow-md font-bold"
    else
      "text-blue-100 hover:text-white hover:bg-blue-800 rounded-lg transition-colors font-medium"
    end
  end

  def sidebar_icon_class(active)
    active ? "text-brand-orange" : "text-blue-300 group-hover:text-white transition-colors"
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
