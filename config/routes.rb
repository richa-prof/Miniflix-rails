require 'sidekiq/web'
require 'constraints/blog_subdomain_constraint'

Rails.application.routes.draw do
  mount S3Multipart::Engine => "/s3_multipart"
  mount Ckeditor::Engine => '/ckeditor'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web, at: '/sidekiq'

  # TODO: Need to confirm regarding the response on rails root page.
  # get '/' => 'welcome#index'

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

    resources :movies do
      collection do
        get 'add_movie_details/:id' => "movies#add_movie_details", as: :add_movie_details
      end
      resources :movie_captions, except: [:show]
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
        put :update_profile
        put :send_verification_code
        put :verify_verification_code
        get :my_activity
        get :make_invalid_for_thankyou_page
        get :billing_details
        get :stripe_card_details
      end
      resources :paypal_payments, only: [] do
        collection do
          get 'complete/:user_id' => 'paypal_payments#complete'
          get 'cancel/:user_id' => 'paypal_payments#cancel'
          get 'update_payment/:user_id' => 'paypal_payments#update_payment'
          get 'cancel_update/:user_id' =>  'paypal_payments#cancel_update'
          get 'upgrade_payment/:user_id' => 'paypal_payments#upgrade_payment'
          get 'cancel_upgrade/:user_id' =>  'paypal_payments#cancel_upgrade'
          post 'hook'
        end
      end

      resource :payments, only: [:create, :update] do
        put :upgrade
        get :suspend
        get :reactivate
      end

      resource :stripe_payments, only: [] do
        post 'hook'
      end
    end
  end

  # API's for mobile applications
  namespace :api do
    namespace :vm1 do
    post 'users/contact_us' => 'users#contact_us'
    # TODO: Currently there is no such action `get_billing_detail_of_the_user` .
    # Need to confirm on this.
    # post 'users/get_billing_detail_of_the_user' => 'users#get_billing_detail_of_the_user'
    post 'users/payment_history' => 'users#payment_history'
    post 'users/email_and_notification'
    post 'users/update_profile'
    post 'users/update_registration_plan'
    post 'users/get_user_by_id'
    delete 'users/:id' => 'users#destroy'

    get 'genres/genres' => 'genres#genres'
    post 'genres/genres_wise_movies' =>'genres#genres_wise_movies'
    post 'genres/id_wise_gener' => 'genres#id_wise_gener_with_movie',as: :id_wise_gener

    post 'movies/get_movie_detail' => 'movies#get_movie_detail'
    post 'movies/get_movie_detail/:id' => 'movies#get_movie_detail'
    post 'movies/get_all_movie_by_movie_name_or_genre_name' => 'movies#get_all_movie_by_movie_name_or_genre_name'
    post 'movies/search_movie_with_genre' => 'movies#search_movie_with_genre'
    post 'movies/add_movie_my_list' => 'movies#add_movie_my_list'
    post 'movies/remove_my_list_movie' => 'movies#remove_my_list_movie'
    post 'movies/my_list_movies' => 'movies#my_list_movies'
    post 'movies/add_to_recently_watched' => 'movies#add_to_recently_watched'
    post 'movies/add_multiple_to_recently_watched' => 'movies#add_multiple_to_recently_watched'
    post 'movies/add_multiple_to_recently_watched_visitor' => 'movies#add_multiple_to_recently_watched_visitor'
    post 'movies/add_to_recently_watched_visitor' => 'movies#add_to_recently_watched_visitor'
    post 'movies/get_watched_movie_count_visitor' => 'movies#get_watched_movie_count_visitor'
    get  'movies/latest_movies' => 'movies#latest_movies'

    post 'sessions/sign_in', :defaults => { :format => 'json' }
    post 'sessions/sign_up'
    post 'sessions/sign_out'
    post 'sessions/social_sign_in'
    post 'sessions/change_password'
    post 'sessions/edit_phone_number'
    post 'sessions/forgot_password'
    delete 'sessions/sign_out'

    # TODO: Currently there is no such action `update_payment_info` .
    # Need to confirm on this.
    # post 'payments/update_payment_info'

    # TODO: Currently there is no such action `update_android_payment_payment_info` .
    # Need to confirm on this.
    # post 'payments/update_android_payment_payment_info'
    post 'payments/cancel_subscription'
    post 'payments/reactive_cancelled_payment'
    post 'payments/update_receipt_data_of_user' => 'payments#update_receipt_data_of_user'

    post 'notifications/get_notifications' => 'notifications#get_notifications'
    post 'notifications/delete_notifications' => 'notifications#delete_notifications'
    post 'notifications/send_test_notification' => 'notifications#send_test_notification'
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
