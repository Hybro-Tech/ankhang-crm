source "https://rubygems.org"

ruby "3.3.10"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# ============================================
# AnKhangCRM Custom Gems (TASK-003)
# ============================================

# Authentication & Authorization
gem "cancancan"    # Authorization / RBAC
gem "devise"       # User authentication

# Background Jobs
gem "redis", ">= 4.0.1"
gem "sidekiq", "~> 7.0"

# Utilities
gem "kaminari" # Pagination

# ============================================
# Development & Test Groups
# ============================================

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
end

group :development do
  gem "bullet"                         # N+1 detection
  gem "rubocop-rails", require: false  # Linting
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
