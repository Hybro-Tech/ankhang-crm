# frozen_string_literal: true

Rails.application.routes.draw do
  # Demo page for testing UI components (TASK-006)
  get "demo", to: "demo#index", as: :demo
  
  # Root path - temporarily set to demo for testing
  root "demo#index"

  # Mock Devise routes for UI testing (TASK-006)
  get "login", to: "demo#index", as: :new_user_session
  delete "logout", to: "demo#index", as: :destroy_user_session

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
