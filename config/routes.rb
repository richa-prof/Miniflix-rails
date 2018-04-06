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

    resources :staffs, only: [:index, :new, :create, :destroy]
    get '/' => 'staffs#index'
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
      end
    end
  end

  # Starts routing for Blog Feature
  constraints Constraints::BlogSubdomainConstraint do
    devise_for :users, as: :staff, :controllers => {:registrations => "registrations"}

    root to: 'blogs#dashboard'
    resources :blogs, except: [:index] do
      resources :likes, only: [:create, :destroy]
      resources :comments, only: [:create, :index]
    end
    get 'blog_profile/:id' => 'blogs#blog_profile', as: 'blog_profile'
  end

end
