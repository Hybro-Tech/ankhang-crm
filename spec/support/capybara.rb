# frozen_string_literal: true

require "capybara/rspec"

# Configure Capybara for RSpec system tests
Capybara.app = Rails.application
Capybara.default_driver = :rack_test
Capybara.server = :puma, { Silent: true }

# Use localhost to avoid Rails HostAuthorization blocking www.example.com
Capybara.default_host = "http://127.0.0.1"
Capybara.server_host = "127.0.0.1"

RSpec.configure do |config|
  config.include Capybara::DSL, type: :system

  config.before(:each, type: :system) do
    driven_by :rack_test
    # Force host headers to match 127.0.0.1
    host! "127.0.0.1" if respond_to?(:host!)
  end
end
