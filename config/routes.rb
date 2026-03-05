Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors and load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Authentication routes
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  get "logout", to: "sessions#destroy"
  get "auth/:provider/callback", to: "sessions#omniauth"
  post "auth/:provider/callback", to: "sessions#omniauth"
  get "auth/failure", to: "sessions#failure"

  # Maps
  resources :maps do
    member do
      get :image_url
    end
    resources :rooms, except: [:show] do
      collection do
        get :editor
      end
    end
  end

  # Resources
  resources :resources do
    collection do
      get :feed, defaults: { format: :rss }
      get :export, defaults: { format: :json }
    end
  end

  # Site Configuration (singleton)
  resource :site_config, only: [:show, :edit, :update], path: "site-config", controller: "site_config"

  # Activity Journal (admin only)
  get "journal", to: "journal#index", as: :journal

  # Search
  get "search", to: "search#index", as: :search

  # RAG export
  get "rag", to: "rag#show", as: :rag, defaults: { format: :json }

  # Defines the root path route ("/")
  root "home#index"
end
