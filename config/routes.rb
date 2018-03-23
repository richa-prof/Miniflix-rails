Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount_devise_token_auth_for 'User', at: 'api/v1/auth', controllers: {
    sessions: "api/v1/sessions",
    registrations: "api/v1/registrations",
    token_validations: "api/v1/token_validations",
    passwords: "api/v1/passwords"
  }

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
          get :add_to_playlist
          get :remove_from_playlist
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
    end
  end
end
