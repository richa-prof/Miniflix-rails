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
      resource :movies, only: [] do
        get :featured_movie, on: :collection
      end
      resources :contact_us, only: [:create]
    end
  end
end
