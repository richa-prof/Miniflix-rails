Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions: "sessions",
    registrations: "registrations"
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resource :mobile_apps, only: [] do
        get :share_app_link
      end
      resources :genres, only: [:index] do
        resources :movies, only: [:index]
      end
      resources :movies, only: [] do
        collection do
          get :featured_movie
          get :search
          get :my_playlist
        end
        member do
          get :add_to_playlist
          get :remove_from_playlist
        end
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
