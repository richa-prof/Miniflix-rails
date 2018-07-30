namespace :copy_background_images do
  desc "Copy the old background_images to new database"
  task :copy_background_images_to_new_db, [:old_database, :old_user, :old_password, :new_database, :new_user, :new_password] => [:environment] do |t, args|
    old_database = args[:old_database]
    old_user = args[:old_user]
    old_password = args[:old_password]
    new_database = args[:new_database]
    new_user = args[:new_user]
    new_password = args[:new_password]

    @client1 = Mysql2::Client.new host: "localhost", username: old_user, password: old_password, database: old_database
    @client2 = Mysql2::Client.new host: "localhost", username: new_user, password: new_password, database: new_database

    results = @client1.query("SELECT * FROM background_images")
    results.each do |row|
      Rails.logger.debug ">>>>>> background_images full information >>>>>>"
      Rails.logger.debug "#{row}"
      puts ">>>>>> background_images full information >>>>>>"
      puts "#{row}"

      @client2.query(background_images_insert_query(row))
      Rails.logger.debug ">>>>>>Data inserted:: #{background_images_insert_query(row)} >>>>>>"
      puts ">>>>>>Data inserted:: #{background_images_insert_query(row)} >>>>>>"
    end
  end

  def background_images_insert_query(row)
    "
      INSERT INTO background_images (
        id, image_file, is_set, created_at, updated_at
      )
      VALUES (
        #{row["id"]}, '#{row["backaground_image"]}', '#{row["is_set"]}', #{change_date_time_into_string(row["created_at"])}, #{change_date_time_into_string(row["updated_at"])}
      )
    "
  end

  def change_date_time_into_string(date)
    date.present? ? "'#{date.strftime('%Y-%m-%d %H:%M:%S')}'" : nil.to_json
  end

end

# rake copy_background_images:copy_background_images_to_new_db[:old_database,:old_db_user,:old_db_password,:new_database_name,:new_db_user,:new_db_password]
# For example:
# rake copy_background_images:copy_background_images_to_new_db['mini0_devlopment','root','root','miniflix_dev','root','root']
