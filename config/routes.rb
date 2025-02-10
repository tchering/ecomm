Rails.application.routes.draw do
  namespace :admin do
    resources :orders
    resources :stocks do
      get "by_product/:product_id", to: "stocks#by_product", on: :collection, as: :by_product
    end
    resources :products do
      delete "images/:id", to: "products#destroy_image", as: :image
    end
    resources :categories
  end
  devise_for :admins
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "stores#index"

  authenticated :admin do
    root "admins#dashboard", as: :admin_root
  end
  get "admin", to: "admins#dashboard"
end
