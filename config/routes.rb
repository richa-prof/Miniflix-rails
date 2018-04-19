require 'sidekiq/web'
require 'constraints/blog_subdomain_constraint'

Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web, at: '/sidekiq'

  mount_devise_token_auth_for 'User', at: 'api/v1/auth', controllers: {
    sessions: "api/v1/sessions",
    registrations: "api/v1/registrations",
    token_validations: "api/v1/token_validations",
    passwords: "api/v1/passwords",
    omniauth_callbacks: "api/v1/omniauth_callbacks"
  }


  namespace :admin do
    devise_for :users, as: :admin, controllers: {
      sessions: 'admin/sessions',
    }

    resources :staffs, only: [:index, :new, :create, :destroy] do
      collection do
        get 'check_email'
      end
    end

    get '/' => 'staffs#index'
    get 'educational_users' => 'users#educational_users'
    get 'monthly_users' => 'users#monthly_users'
    get 'annually_users' => 'users#annually_users'
    get 'freemium_users' => 'users#freemium_users'
    get 'get_user_payment_details/:id' => 'users#get_user_payment_details', as: :get_user_payment_details

    resources :users, only: [:index, :destroy]

    resources :visitors, only: [:index, :destroy]

    resources :contact_user_replies, only: [:create]

    resources :background_images
    resources :free_members do
      collection do
        get 'check_email' => 'free_members#check_email'
      end
    end

    resources :genres do
      collection do
        get 'check_genre_name/:id' => 'genres#check_genre_name', as: :check_genre_name
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resource :mobile_apps, only: [] do
        get :share_app_link
      end
      resources :genres, only: [:index] do
        resources :movies, only: [:index]
      end
      resources :movies, only: [:show] do
        collection do
          get :featured_movie
          get :search
          get :my_playlist
          get :popular_movies
        end
        member do
          get :add_and_remove_to_my_playlist
        end
        resources :user_video_last_stops, only: [:create]
      end
      resources :contact_us, only: [:create]
      resources :notifications, only: [:index] do
        delete :delete_notifications, on: :collection
      end
      resources :user_email_notifications, only: [:index]
      resource :user_email_notification, only: [:update]
      resource :users, only: [] do
        put :send_verification_code
        put :verify_verification_code
        get :my_activity
        get :make_invalid_for_thankyou_page
      end
      resources :paypal_payments, only: [] do
        collection do
          get 'complete/:user_id' => 'paypal_payments#complete'
          get 'cancel/:user_id' => 'paypal_payments#cancel'
          post 'hook'
        end
      end

      resource :payments, only: [:create]
    end
  end

  # Starts routing for Blog Feature
  constraints Constraints::BlogSubdomainConstraint do
    devise_for :users, as: :staff, :controllers => {:registrations => "registrations"}

    root to: 'blogs#dashboard'
    resources :blogs do
      resources :likes, only: [:create, :destroy]
      resources :comments, only: [:create, :index]
    end
    get 'profile/:id' => 'blogs#blog_profile', as: 'profile'
  end

  get 'send_download_link' => 'mobile_apps#send_download_link'
end
