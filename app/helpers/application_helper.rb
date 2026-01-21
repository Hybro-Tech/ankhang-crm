module ApplicationHelper
  # Sidebar link helper
  def sidebar_link(title, path, icon, is_active = false)
    active_class = is_active || current_page?(path) ? 
      "bg-white text-brand-blue rounded-lg shadow-md font-bold" : 
      "text-blue-100 hover:text-white hover:bg-blue-800 rounded-lg transition-colors font-medium"
    
    icon_class = is_active || current_page?(path) ? "text-brand-orange" : "text-blue-300 group-hover:text-white transition-colors"

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
  def breadcrumb(&block)
    content_for(:breadcrumb, &block)
  end
end
