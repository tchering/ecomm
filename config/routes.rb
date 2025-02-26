Rails.application.routes.draw do
  get "wishlists/show"
  get "wishlists/toggle"
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
  resources :products, only: [:show]
  resources :cart_items, only: [:create, :update, :destroy]
  resource :cart, only: [:show, :destroy]

  # Checkout routes
  get "checkout", to: "checkouts#new"
  post "checkout", to: "checkouts#create"
  get "orders/:id/confirmation", to: "checkouts#confirmation", as: "order_confirmation"

  # Public FAQ routes
  resources :faqs, only: [:index]

  # Admin routes
  # Use devise for admin authentication
  devise_for :admins

  # Admin authenticated routes
  authenticate :admin do
    namespace :admin do
      root to: "dashboard#index"
      get "/", to: "dashboard#index", as: :dashboard
      get "/inventory", to: "dashboard#inventory", as: :inventory_dashboard

      resources :users do
        member do
          patch :deactivate
        end
      end

      resources :products do
        member do
          delete :destroy_image
        end
        collection do
          post :bulk_action
        end

        resources :stocks do
          collection do
            get :by_product
            get :movements
            post :adjust
            post :restock
          end
        end

        member do
          delete "images/:image_id", to: "products#destroy_image", as: :image
        end
      end

      resources :stocks, only: [:index] do
        post :restock, on: :member
      end

      resources :warehouses
      resources :stock_movements, only: [:index, :show]

      resources :categories
      resources :orders do
        member do
          patch :update_status
        end
        collection do
          get :by_status
        end
      end

      resources :reviews do
        member do
          patch :approve
          patch :reject
        end
      end
    end
  end

  # Simple admin redirect
  get "admin", to: redirect("/admins/sign_in")

  # Chatbot API routes
  namespace :api do
    resources :chatbot, only: [] do
      collection do
        post :message
        get :faqs
      end
    end
  end

  # Wishlist routes
  resource :wishlist, only: [:show] do
    post "toggle", on: :collection
  end

  get "/wishlists/count", to: "wishlists#count"

  resources :products do
    resources :reviews do
      member do
        post "vote"
      end
    end
  end
end
