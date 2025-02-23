Rails.application.routes.draw do
  devise_for :users, controllers: {
                       sessions: "users/sessions",
                       registrations: "users/registrations",
                       confirmations: "users/confirmations",
                       passwords: "users/passwords",
                     }

  # Profile routes
  resource :profile, only: [:show, :edit, :update]
  resources :addresses do
    member do
      patch :set_default
    end
  end

  # Orders routes
  resources :orders, only: [:index, :show] do
    member do
      get :invoice
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "stores#index"

  # Store routes
  resources :stores, only: [:index, :show]
  resources :cart_items, only: [:create, :update, :destroy]
  resource :cart, only: [:show, :destroy]

  # Checkout routes
  get "checkout", to: "checkouts#new"
  post "checkout", to: "checkouts#create"
  get "orders/:id/confirmation", to: "checkouts#confirmation", as: "order_confirmation"

  # Public FAQ routes
  resources :faqs, only: [:index]

  # Admin routes
  authenticated :admin do
    root "admins#dashboard", as: :admin_root
  end

  get "admin", to: "admins#dashboard"

  namespace :admin do
    resources :faqs
    resources :orders do
      collection do
        get "by_status/:status", to: "orders#by_status", as: :by_status
      end
    end
    resources :stocks do
      collection do
        get "by_product/:product_id", to: "stocks#by_product", as: :by_product
      end
    end
    resources :products do
      delete "images/:id", to: "products#destroy_image", as: :image
    end
    resources :categories
  end

  # Chatbot API routes
  namespace :api do
    resources :chatbot, only: [] do
      collection do
        post :message
        get :faqs
      end
    end
  end

  # Devise routes
  devise_for :admins
end
