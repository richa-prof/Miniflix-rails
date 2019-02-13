require 'sidekiq/web'
require 'constraints/admin_subdomain_constraint'
require 'constraints/api_subdomain_constraint'
require 'constraints/blog_subdomain_constraint'

Rails.application.routes.draw do
  mount S3Multipart::Engine => "/s3_multipart"
  mount Ckeditor::Engine => '/ckeditor'

  # Starts common routing
  get 'send_download_link' => 'mobile_apps#send_download_link'
  resources :movies, only: [:show]

  # Starts routing for API subdomain
  constraints Constraints::ApiSubdomainConstraint do

    mount_devise_token_auth_for 'User', at: 'api/v1/auth', controllers: {
      sessions: "api/v1/sessions",
      registrations: "api/v1/registrations",
      token_validations: "api/v1/token_validations",
      passwords: "api/v1/passwords",
      omniauth_callbacks: "api/v1/omniauth_callbacks"
    }

    get 'android_payment_view' => 'payments#android_payment_view'
    post 'do_payment_android/:id' => 'payments#do_payment_android'
    get 'android_payment_old_user_view' => 'payments#android_payment_old_user_view'
    patch 'android_payment_process_for_old_user/:id' => 'payments#android_payment_process_for_old_user'
    get 'paypal_success/:user_id' => 'payments#paypal_success'
    get 'paypal_cancel/:user_id' => 'payments#paypal_cancel'

    # API's for React Site
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
            get :battleship
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

        resources :seo_metas, only: [:index]
      end
    end

    # API's for mobile applications
    namespace :api do
      namespace :vm1 do
      get 'welcome/app_latest_version' => 'welcome#app_latest_version'

      post 'users/contact_us' => 'users#contact_us'
      post 'users/payment_history' => 'users#payment_history'
      post 'users/email_and_notification'
      post 'users/update_profile'
      post 'users/update_registration_plan'
      post 'users/get_user_by_id'
      delete 'users/:id' => 'users#destroy'
      get 'users/check_email_exists' => 'users#check_email_exists'

      get 'genres/genres' => 'genres#genres'
      post 'genres/genres_wise_movies' =>'genres#genres_wise_movies'
      get 'genres/genres_with_latest_movie' =>'genres#genres_with_latest_movie'
      post 'genres/id_wise_gener' => 'genres#id_wise_gener_with_movie',as: :id_wise_gener

      post 'serials/get_serial_detail/:id' => 'serials#get_serial_detail'

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

      post 'payments/cancel_subscription'
      post 'payments/reactive_cancelled_payment'
      post 'payments/ios_webhook'
      post 'payments/update_receipt_data_of_user' => 'payments#update_receipt_data_of_user'

      post 'notifications/get_notifications' => 'notifications#get_notifications'
      post 'notifications/delete_notifications' => 'notifications#delete_notifications'
      post 'notifications/send_test_notification' => 'notifications#send_test_notification'
      post 'notifications/mark_notification' => 'notifications#mark_notification'
      get 'notifications/mark_unread_notifications' => 'notifications#mark_unread_notifications'
      post 'notifications/mark_all_notifications' => 'notifications#mark_all_notifications'
      end
    end
  end

  # Starts routing for Admin subdomain
  constraints Constraints::AdminSubdomainConstraint do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    mount Sidekiq::Web, at: '/sidekiq'

    get '/' => 'admin/dashboard#index'

    namespace :admin do
      devise_for :users, as: :admin, controllers: {
        sessions: 'admin/sessions',
      }

      resources :staffs, only: [:index, :new, :create, :destroy] do
        collection do
          get 'check_email'
        end
      end

      resources :marketing_staffs, only: [:index, :new, :create, :destroy] do
        collection do
          get 'check_email'
        end
      end

      get '/' => 'dashboard#index'
      get 'dashboard' => 'dashboard#index'
      get 'educational_users' => 'users#educational_users'
      get 'monthly_users' => 'users#monthly_users'
      get 'annually_users' => 'users#annually_users'
      get 'freemium_users' => 'users#freemium_users'
      get 'premium_users' => 'users#premium_users'
      get 'get_monthly_revenue/:id' => 'users#get_monthly_revenue', as: :get_monthly_revenue
      get 'get_user_payment_details/:id' => 'users#get_user_payment_details', as: :get_user_payment_details

      resources :users, only: [:index, :destroy]

      resources :visitors, only: [:index, :destroy]

      resources :contact_user_replies, only: [:create]

      resources :blog_subscribers, only: [:index, :destroy]
      resources :mailchimp_groups

      resources :background_images
      resources :free_members do
        collection do
          get 'check_email' => 'free_members#check_email'
        end
      end

      resources :movies do
        collection do
          get 'add_movie_details/:id' => "movies#add_movie_details", as: :add_movie_details
          get 'upload_movie_trailer/:id' => "movies#upload_movie_trailer", as: :upload_movie_trailer
          post 'save_uploaded_movie_trailer' => "movies#save_uploaded_movie_trailer", as: :save_uploaded_movie_trailer
        end
        resources :movie_captions, except: [:show]
      end

      resources :genres do
        collection do
          get 'check_genre_name/:id' => 'genres#check_genre_name', as: :check_genre_name
        end
      end

      resources :serials do
        collection do
          get 'choose_mode' => 'serials#choose_mode'
          get 'new2' => 'serials#new2'
          get 'new3' => 'serials#new3'
          get 'new4' => 'serials#new4'
        end
      end
    end


    namespace :marketing_staff do
      devise_for :users, as: :marketing_staff, controllers: {
        sessions: 'marketing_staff/sessions',
      }

      resources :genres, only: [:index, :show, :edit, :update] do
        collection do
          get 'check_genre_name/:id' => 'genres#check_genre_name', as: :check_genre_name
        end
      end

      resources :seo_metas
    end
  end

  # Starts routing for Blog Feature
  constraints Constraints::BlogSubdomainConstraint do
    # Indexing robots.txt route
    get '/robots', to: redirect('/robots.txt'), format: false
    get '/robots.:format' => 'robots#index'

    get '/sitemap.xml.gz', to: redirect("#{ENV['CLOUD_FRONT_URL']}sitemaps/sitemap.xml.gz"), as: :sitemap

    devise_for :users, as: :staff, :controllers => { registrations: 'registrations',
                                                     sessions: 'sessions' }

    root to: 'blogs#dashboard'
    resources :blogs do
      resources :likes, only: [:create, :destroy]
      resources :comments, only: [:create, :index], :constraints => -> (req) { req.xhr? }
    end
    resources :blog_subscribers, only: [:create], :constraints => -> (req) { req.xhr? }
    get 'profile/:id' => 'blogs#blog_profile', as: 'profile'
  end

  resources :api_docs, only: [] do
    collection do
      get :v1
      get :vm1
      get '/v1/api_v1', to: "api_docs#api_v1", constraints: { format: 'json' }
      get '/vm1/api_vm1', to: "api_docs#api_vm1", constraints: { format: 'json' }
    end
  end
end
