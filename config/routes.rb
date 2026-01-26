# frozen_string_literal: true

Rails.application.routes.draw do
  # TASK-014: Use custom controllers for auth logging
  devise_for :users, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords"
  }

  # Roles management (TASK-016)
  resources :roles do
    member do
      post :clone
    end
  end
  resources :users
  resources :teams


  # Demo page for testing UI components (TASK-006)
  get "demo", to: "demo#index", as: :demo

  # Root path - temporarily set to demo for testing
  root "demo#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
