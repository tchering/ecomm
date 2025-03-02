Rails.application.routes.draw do
  namespace :admin do
    resources :contact_inquiries
    get "contact_inquiries/index"
    get "contact_inquiries/show"
    get "contact_inquiries/respond"
    get "newsletters/index"
    get "newsletters/new"
    get "newsletters/create"
    get "newsletters/edit"
    get "newsletters/update"
    get "newsletter_subscriptions/index"
  end
  get "contact_inquiries/new"
  get "contact_inquiries/create"
  get "newsletter_subscriptions/create"
  get "newsletter_subscriptions/unsubscribe"
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
  devise_for :admin_users, controllers: {
                             sessions: "admin_users/sessions",
                           }

  # Admin authenticated routes
  authenticate :admin_user do
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

      # Newsletter subscriptions
      resources :newsletter_subscriptions

      # Newsletter management
      resources :newsletters do
        member do
          post :send_now
          post :duplicate
          get :preview
        end
        collection do
          get :analytics
          get :templates
        end
      end

      resources :newsletter_subscriptions do
        collection do
          get :export
          post :import
          get :segments
        end
      end

      # Newsletter tracking
      get "newsletter/:id/tracking", to: "newsletters#tracking", as: :newsletter_tracking
      get "newsletter/:id/redirect", to: "newsletters#redirect", as: :newsletter_redirect

      # Contact inquiries
      resources :contact_inquiries, only: [:index, :show] do
        member do
          post :respond
          post :mark_as_resolved
          post :mark_as_spam
        end
      end

      # Notifications
      resources :notifications, only: [:index] do
        member do
          patch :mark_as_read
        end
        collection do
          post :mark_all_as_read
        end
      end
    end
  end

  # Simple admin redirect
  get "admin", to: redirect("/admin_users/sign_in")

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

  # Newsletter subscriptions
  resources :newsletter_subscriptions, only: [:create] do
    get :unsubscribe, on: :collection
  end

  # Contact inquiries
  resources :contact_inquiries, only: [:new, :create]

  # Sidekiq Web UI
  require "sidekiq/web"
  authenticate :admin_user do
    mount Sidekiq::Web => "/admin/sidekiq"
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

  resources :newsletter_subscriptions do
    collection do
      get :export
      post :import
    end
    member do
      post :send_newsletter
    end
  end

  resources :contact_inquiries do
    member do
      post :respond
      post :mark_as_resolved
      post :mark_as_spam
    end
  end

  # Static Pages
  get "about", to: "pages#about", as: :about
  get "careers", to: "pages#careers", as: :careers
  get "press", to: "pages#press", as: :press
  get "blog", to: "pages#blog", as: :blog
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service
  get "cookie-policy", to: "pages#cookie_policy", as: :cookie_policy
  get "accessibility", to: "pages#accessibility", as: :accessibility
end
