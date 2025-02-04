Rails.application.routes.draw do
  resources :providers
  resources :regions
  root "home#index"
  get "home/index", as: :home
  resource :session, except:[:new]
  resources :passwords, except: [:new], param: :token
  resource :registration, only: %i[new create]
  resources :regions
  resources :providers
  resources :languages, only: %i[index show new create edit update]

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "home/index", as: :home
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "connexion", to: "sessions#new"
  get 'reset_password', to:"passwords#new"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  resources :users
  # Defines the root path route ("/")
  root "home#index"
end
