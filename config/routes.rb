# frozen_string_literal: true

Rails.application.routes.draw do
  get "dashboard/index"
  get "dashboard/call_center"
  get "dashboard/call_center_stats", to: "dashboard#call_center_stats", as: :call_center_stats
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
  resources :teams
  resources :users, except: [:show]
  resources :holidays, except: [:show]
  resources :saturday_schedules

  # TASK-019/020/021: Contacts & Service Types
  resources :contacts do
    member do
      post :pick
      post :update_status  # TASK-051: State Machine
    end
    collection do
      get :check_phone
      get :check_identity
      get :recent
    end
    # TASK-023: Interactions for care history
    resources :interactions, only: %i[create destroy]
  end
  resources :service_types
  resources :sources

  # TASK-057: Notifications
  resources :notifications, only: [:index] do
    member do
      post :mark_as_read
    end
    collection do
      get :dropdown
      post :mark_all_as_read
      get :unread_count
    end
  end

  # TASK-053: Admin Settings
  namespace :admin do
    resource :settings, only: %i[show update]
  end

  # Sales Workspace (TASK-050 v2: Productivity-focused screen)
  get "sales/workspace", to: "sales_workspace#show", as: :sales_workspace
  get "sales/workspace/tab_new_contacts", to: "sales_workspace#tab_new_contacts"
  get "sales/workspace/tab_needs_update", to: "sales_workspace#tab_needs_update"
  get "sales/workspace/tab_in_progress", to: "sales_workspace#tab_in_progress"
  get "sales/workspace/preview/:id", to: "sales_workspace#preview", as: :sales_workspace_preview
  get "sales/kanban", to: "sales_workspace#kanban", as: :sales_kanban
  patch "sales/kanban/update_status/:id", to: "sales_workspace#update_status", as: :sales_kanban_update_status

  # Demo page for testing UI components (TASK-006)
  get "demo", to: "demo#index", as: :demo

  # Root path - Dashboard with role-based view
  root "dashboard#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
