# frozen_string_literal: true

Rails.application.routes.draw do
  get "dashboard/index"
  get "dashboard/call_center"
  get "dashboard/call_center_overview", to: "dashboard#call_center_overview", as: :call_center_overview
  get "dashboard/call_center_stats", to: "dashboard#call_center_stats", as: :call_center_stats

  # Hidden System Monitoring Portal (super_admin only)
  get "solid", to: "admin/solid#index", as: :solid_portal

  # TASK-014: Use custom controllers for auth logging
  devise_for :users, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords"
  }

  # TASK-PROFILE: User profile management
  resource :profile, only: %i[show update] do
    member do
      patch :update_password
      delete :destroy_avatar
    end
  end

  # User personal settings (notification preferences)
  resource :settings, only: [:show], controller: 'settings'

  # Roles management (TASK-016)
  resources :roles do
    member do
      post :clone
    end
  end

  # TASK-REGION: Region management for Admin
  resources :regions do
    member do
      patch :toggle_active
    end
  end

  # TASK-061: Province management for Admin
  resources :provinces do
    member do
      patch :toggle_active
    end
  end
  # TASK-052: Teams namespace for Lead approval workflow (MUST be before resources :teams)
  namespace :teams do
    resources :reassign_requests, only: [:index] do
      member do
        post :approve
        post :reject
      end
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
      post :update_status # TASK-051: State Machine
      get :qr_code
    end
    collection do
      get :check_phone
      get :check_identity
      get :recent
    end
    # TASK-023: Interactions for care history
    resources :interactions, only: %i[create destroy]
    # TASK-052: Admin can create reassign/unassign requests
    resources :reassign_requests, only: %i[new create], controller: "reassign_requests"
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

  # TASK-056: Web Push Subscriptions
  resources :push_subscriptions, only: %i[create destroy] do
    collection do
      get :vapid_public_key
    end
  end

  # TASK-053: Admin Settings & Solid Stack Monitoring (super_admin only)
  namespace :admin do
    resource :settings, only: %i[show update]

    # Hidden Solid Stack monitoring portal (accessible via /solid)
    resources :solid, only: [:index], controller: "solid"
    # Custom-built Solid Stack monitoring dashboards with management actions
    resource :solid_queue, only: [:show], controller: "solid_queue" do
      member do
        post :retry
        post :retry_all
        delete :discard
        delete :discard_all
        delete :clear_completed
      end
      collection do
        get :pending
        get :scheduled
        get :failed
        get :completed
      end
    end
    resource :solid_cache, only: [:show], controller: "solid_cache" do
      member do
        delete :clear_all
        delete :clear_old
      end
      collection do
        delete "entry/:id", action: :destroy, as: :delete_entry
      end
    end
    resource :solid_cable, only: [:show], controller: "solid_cable" do
      delete :cleanup, on: :member
    end

    # TASK-LOGGING: Activity Logs and User Events viewer (super_admin only)
    resources :logs, only: [:index, :show], controller: "logs" do
      collection do
        get :events
        get :archives
      end
    end
  end

  # Sales Workspace (TASK-050 v2: Productivity-focused screen)
  get "sales/workspace", to: "sales_workspace#show", as: :sales_workspace
  get "sales/workspace/tab_new_contacts", to: "sales_workspace#tab_new_contacts"
  get "sales/workspace/tab_needs_update", to: "sales_workspace#tab_needs_update"
  get "sales/workspace/tab_potential", to: "sales_workspace#tab_potential" # TASK-064: Renamed from tab_in_progress
  get "sales/workspace/tab_pending_requests", to: "sales_workspace#tab_pending_requests" # TASK-052
  get "sales/workspace/preview/:id", to: "sales_workspace#preview", as: :sales_workspace_preview
  get "sales/workspace/more_appointments", to: "sales_workspace#more_appointments", as: :sales_workspace_more_appointments
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
