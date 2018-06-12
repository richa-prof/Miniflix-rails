namespace :import_users_list do
  desc 'import users and save the list in CSV file for mailchimp email campaigns'
  task import_users_for_mailchimp_campaigns: :environment do
    CSV.open("tmp/users_list_for_campaigns.csv","w") do |csv|
      column_names = ['Email Address', 'First Name', 'Last Name', 'Address']
      csv << column_names

      User.find_each(batch_size: 100) do |user|
        csv << [ user.email, user.name, '', '' ]
      end
    end
  end

end

# Ref:
# RAILS_ENV=production bundle exec rake import_users_list:import_users_for_mailchimp_campaigns
# scp -i ../Miniflix.pem deploy@52.33.20.12:/data/apps/production/miniflix-rails/current/tmp/users_list_for_campaigns.csv /home/user/projects/miniflix
