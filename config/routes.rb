Rails.application.routes.draw do
  get "user_roles/assign_driver"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "auth/login"
  post "auth/admin/login", to: "auth#admin_login"
  post "auth/signup"
  post "auth/driver/signup", to: "auth#driver_signup"

  get "user_profile", to: "user_profiles#show"

  resources :user_profiles do
    member do
      put "update_kyc"
    end
  end

  resources :users, only: [ :index, :show ]

  resources :user_roles, only: [] do
    collection do
      post :assign_driver
    end
  end
end
