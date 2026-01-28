# config/initializers/field_error_proc.rb
# Disable the default <div class="field_with_errors"> wrapper which breaks Tailwind layouts
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  html_tag
end
