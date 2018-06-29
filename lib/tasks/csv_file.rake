# These rake task for csv_file generate which is used for list all users and also it is listed users where sign_up_from and register_plan  is nil
# Currently, no need to rake task
namespace :csv_file do
  desc "CSV file generate"
  task csv_file_generate: :environment do
    CSV.open("tmp/user_details.csv","w") do |csv|
      column_names = ['id', 'email', 'name', 'sign_up_from', 'is_free', 'registration_plan', 'subscription_plan', 'provider', 'payment_method_available', 'customer_id', 'subscription_id', 'receipt_url']
      csv << column_names
      User.all.each do |user|
        csv << [user.id, user.email, user.name, user.sign_up_from, user.is_free, user.registration_plan, user.subscription_plan_status, user.provider, is_payment_method_available?(user), user.customer_id, user.subscription_id, is_receipt_url_present?(user)]
      end
    end
  end

  desc "CSV file generate where sign_up_from and register_plan is nil"
  task csv_file_generate_1: :environment do
    CSV.open("tmp/user_details_with_sign_up_from_and_registration_plan_nil.csv","w") do |csv|
      column_names = ['id', 'email', 'name', 'sign_up_from', 'is_free', 'registration_plan', 'subscription_plan', 'provider', 'payment_method_available', 'customer_id', 'subscription_id']
      csv << column_names
      User.all.each do |user|
        if((user.sign_up_from == nil or user.sign_up_from = '') and (user.registration_plan == nil or user.registration_plan = ''))
          puts "user: #{user.id}, sign_up_from: #{user.sign_up_from}, registration_plan: #{user.registration_plan}"
          csv << [user.id, user.email, user.name, user.sign_up_from, user.is_free, user.registration_plan, user.subscription_plan_status, user.provider, is_payment_method_available?(user), user.customer_id, user.subscription_id]
        end
      end
    end
  end

  def is_receipt_url_present?(user)
    if user.sign_up_from == 'iOS'
      puts user.receipt_data.present? ? 'Yes' : 'No'
      user.receipt_data.present? ? 'Yes' : 'No'
    else
      puts user.receipt_data.present? ? 'Yes' : '-'
      user.receipt_data.present? ? 'Yes' : '-'
    end
  end


  def is_payment_method_available?(user)
    user.user_payment_methods.blank? ? 'NA' : 'Yes'
  end

  desc 'Generate most watched movies CSV file'
  task generate_most_watched_movies_csv_file: :environment do
    CSV.open("tmp/most_watched_movies.csv","w") do |csv|
      column_names = ['movie id', 'movie name', 'movie title', 'views count']
      csv << column_names
      Movie.popular_movies.each do |movie|
        csv << [movie.id, movie.name, movie.title, movie.total_watches]
      end
    end
  end
end

# RAILS_ENV=production bundle exec rake csv_file:generate_most_watched_movies_csv_file
