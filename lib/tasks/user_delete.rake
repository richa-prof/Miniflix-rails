namespace :user_delete do
  desc 'Delete test users'
  task test_user_delete_task: :environment do
    user_logger = Logger.new("#{Rails.root}/log/deleting_temp_user.log")

    user_logger.debug ">>>>>>>>>>> Database total users #{User.count} >>>>>>>>>>>"
    puts "Database total users #{User.count}"

    user_logger.debug "======= Now running rake task for Delete test users from database ======="
    puts "Now running rake task for Delete test users from database"

    count = 0

    csv_text = File.read('lib/tasks/test_user.csv')
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      if(row["test_user"] == "yes")
        count += 1

        user = User.find_by_email(row["Email"]);
        if user.present?
          user_logger.debug "=======Processing for user_email: #{user.email}======="
          puts "=======Processing for user_email: #{user.email}======="

          if user.destroy
            user_logger.debug "Successfully Deleted user_id #{user.id}"
            puts "Successfully Deleted user_id #{user.id}"
          else
            user_logger.debug "Deletion failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
            puts "Deletion failed for user_id: #{user.id} >>> errors:  #{user.errors.full_messages}"
          end
        end
      end
    end

    user_logger.debug "======= Total test users #{count} ======="
    puts "Total test users #{count}"

    user_logger.debug ">>>>>>>>> Remaining database users #{User.count} >>>>>>>>>"
    puts ">>>>>>>>> Remaining database users #{User.count} >>>>>>>>>"
  end
end

# Commands to run the above tasks:
# 1. rake user_delete:test_user_delete_task
