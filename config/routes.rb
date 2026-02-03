Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"
  resources :languages, only: %i[index new create edit update]
  resources :passwords, param: :token
  resources :providers
  resources :regions
  resource :registration, only: %i[new create]
  resource :session
  resources :uploads, only: %i[create destroy]
  resources :users
  resources :tags, only: %i[index show edit update destroy]
  resources :topics do
    member do
      put :archive
      put :unarchive
    end
    resources :tags, only: %i[index], controller: "topics/tags"
  end
  resources :import_reports, only: %i[index show]
  resource :settings, only: [] do
    put :provider, on: :collection
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "home/index", as: :home

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Defines the root path route ("/")

  namespace :api do
    namespace :v1 do
      resources :tags, only: %i[index show]

      namespace :beacons do
        resource :status, only: :show
      end
    end
  end

  root "home#index"
end
