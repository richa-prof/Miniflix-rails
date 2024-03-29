namespace :miniflix do
  desc 'Copy the old data to new database'
  task :insert_data, [:old_database, :old_user, :old_password, :new_database, :new_user, :new_password] => [:environment] do |t, args|
    old_database = args[:old_database]
    old_user = args[:old_user]
    old_password = args[:old_password]
    new_database = args[:new_database]
    new_user = args[:new_user]
    new_password = args[:new_password]

    @client1 = Mysql2::Client.new host: "localhost", username: old_user, password: old_password, database: old_database
    @client2 = Mysql2::Client.new host: "localhost", username: new_user, password: new_password, database: new_database
  
    results = @client1.query("SELECT * FROM users")
    results.each do |row|
      duplicate_email_count = check_duplicate_email(get_email(row["provider"], row["uid"], row["email"]))
      if duplicate_email_count == 0
        Rails.logger.debug "===== user_email : #{row["email"]} full information======="
        Rails.logger.debug "#{row}"
        @client2.query(users_insert_query(row))
        Rails.logger.debug "users table data inserted successfully"
      else
        user_associated_info(row)
      end
    end

    results = @client1.query("SELECT * FROM background_images")
    results.each do |row|
      Rails.logger.debug "===== background_images full information======="
      Rails.logger.debug "#{row}"
      @client2.query(background_images_insert_query(row))
      Rails.logger.debug "background_images table data inserted successfully"
    end

    results = @client1.query("SELECT * FROM contact_us")
    results.each do |row|
      Rails.logger.debug "===== contact_us full information======="
      Rails.logger.debug "#{row}"
      @client2.query(contact_us_insert_query(row))
      Rails.logger.debug "contact_us table data inserted successfully"
    end

    dir = "#{Rails.root.to_s}/db/sql_dump_files"
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    db_tables = ["s3_multipart_uploads", "admin_genres", "admin_movies", "admin_movie_captions", "admin_movie_thumbnails", "admin_paypal_access_tokens", "admin_recurring_plans", "logged_in_users", "free_members", "notifications", "schema_migrations", "temp_users", "user_email_notifications", "user_filmlists", "user_payment_methods", "user_payment_transactions", "user_video_last_stops", "visitors", "movie_versions"]

    db_tables.each do |db_table|
      sh "mysqldump -u#{old_user} -p#{old_password} --no-create-info --complete-insert #{old_database} #{db_table} > #{Rails.root.to_s}/db/sql_dump_files/#{db_table}.sql"
      sh "mysql -u #{new_user} -p#{new_password} #{new_database} < #{Rails.root.to_s}/db/sql_dump_files/#{db_table}.sql"
      Rails.logger.debug "#{db_table} table data inserted successfully"
      puts "#{db_table} table data inserted successfully"
    end


    results = @client1.query("SELECT * FROM contact_user_replies")
    results.each do |row|
      Rails.logger.debug "===== contact_user_replies full information======="
      Rails.logger.debug "#{row}"
      @client2.query(contact_user_replies_insert_query(row))
      Rails.logger.debug "contact_user_replies table data inserted successfully"
    end
  end

  desc 'Copy the users temp_password field value to password field'
  task :copy_users_temp_password_field_data_to_password => :environment do
    User.all.each do |user|
      user.password = user.temp_password
      user.skip_callbacks = true
      if user.save(validate: false)
        Rails.logger.debug "===== password copied for user_id : #{user.id} ======="
      else
        Rails.logger.debug "===== password not copied for user_id : #{user.id} Error: #{user.errors.full_messages} ======="
      end
    end
  end

  def users_insert_query(row)
    insert_sql = "
      INSERT INTO users (
        id, name, email, registration_plan, created_at, updated_at, provider, uid, tokens, image, phone_number, verification_code, subscription_plan_status, cancelation_date, role, customer_id, subscription_id, sign_up_from, receipt_data, is_free, auth_token, expires_at, migrate_user, temp_password
      )
      VALUES (
        '#{row["id"]}', '#{exclude_single_quote(row["name"])}', '#{get_email(row["provider"], row["uid"], row["email"])}', '#{row["registration_plan"]}', #{change_date_time_into_string(row["created_at"])}, #{change_date_time_into_string(row["updated_at"])}, '#{get_provider(row["provider"])}', '#{get_uid(row["uid"], row["email"])}', '#{row["tokens"]}', '#{row["image"]}', '#{row["phone_number"]}', '#{row["verification_code"]}', '#{row["subscription_plan_status"]}', #{change_date_time_into_string(row['cancelation_date'])}, '#{row["role"]}', '#{row["customer_id"]}', '#{row["subscription_id"]}', '#{get_sign_up_from(row["sign_up_from"])}', '#{row["receipt_data"]}', '#{row["is_free"]}', '#{row["auth_token"]}', #{change_date_time_into_string(row['expires_at'])}, 1, '#{SecureRandom.hex(8)}'
      )
    "
  end

  def contact_user_replies_insert_query(row)
    insert_sql = "
      INSERT INTO contact_user_replies (
        id, contact_us_id, message, created_at, updated_at
      )
      VALUES (
        #{row["id"]}, #{row["contact_u_id"]}, '#{row["message"]}', #{change_date_time_into_string(row["created_at"])}, #{change_date_time_into_string(row["updated_at"])}
      )
    "
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

  def contact_us_insert_query(row)
    "
      INSERT INTO contact_us (
        id, name, email, school, occupation, created_at, updated_at
      )
      VALUES (
        #{row["id"]}, '#{exclude_single_quote(row["name"])}', '#{row["email"]}', '#{exclude_single_quote(row["school"])}', '#{get_downcase(row["occupation"])}', #{change_date_time_into_string(row["created_at"])}, #{change_date_time_into_string(row["updated_at"])}
      )
    "
  end

  def user_associated_info(row)
    random_str = "#{SecureRandom.hex(4)}"
    pre_path = "#{Rails.root}/log/"
    target_path = "#{get_email(row["provider"], row["uid"], row["email"])}"

    if File.exists?(target_path)
      target_path = "#{get_email(row["provider"], row["uid"], row["email"])}_#{random_str}"
    end

    user_logger = Logger.new("#{pre_path}#{target_path}")

    user_logger.debug "===================user_email : #{get_email(row["provider"], row["uid"], row["email"])} associate data========================"

    results = @client1.query("select * from user_filmlists where user_id = #{row["id"]}")
    user_logger.debug "====================== filmlists records ==========================="
    log_printer(user_logger, results)

    results = @client1.query("select * from user_payment_methods where user_id = #{row["id"]}")
    user_logger.debug "====================== user_payment_methods records==========================="
    log_printer(user_logger, results)

    results = @client1.query("select * from user_email_notifications where user_id = #{row["id"]}")
    user_logger.debug "====================== user_email_notifications records ==========================="
    log_printer(user_logger, results)

    results = @client1.query("select * from logged_in_users where user_id = #{row["id"]}")
    user_logger.debug "====================== logged_in_users records ==========================="
    log_printer(user_logger, results)

    results = @client1.query("select * from notifications where user_id = #{row["id"]}")
    user_logger.debug "====================== notifications records ==========================="
    log_printer(user_logger, results)

    results = @client1.query("select * from user_video_last_stops where role_id = #{row["id"]}")
    user_logger.debug "====================== user_video_last_stops records ==========================="
    log_printer(user_logger, results)
  end

  def change_date_time_into_string(date)
    date.present? ? "'#{date.strftime('%Y-%m-%d %H:%M:%S')}'" : nil.to_json
  end

  def get_provider(provider)
    provider.blank? ? 'email' : get_downcase(provider)
  end

  def get_uid(uid, email)
    uid.blank? ? email : uid
  end

  def get_email(provider, uid, email)
    !email.blank? ? email : "#{uid}@#{provider}.com"
  end

  def check_duplicate_email(email)
    result = @client2.query("select * from users where email = '#{email}'")
    result.count
  end

  def log_printer(user_logger, results)
    results.each do |row|
      user_logger.debug "#{row}"
    end
  end

  def get_sign_up_from(sign_up_from)
    sign_up_from.blank? ? User.sign_up_froms[:by_admin] : get_downcase(sign_up_from)
  end

  def get_downcase(name)
    name.downcase
  end

  def exclude_single_quote(name)
    if name.present? && name.include?("'")
      name.gsub("'", "")
    else
      name
    end
  end
end

# rake miniflix:insert_data[:old_database,:old_db_user,:old_db_password,:new_database_name,:new_db_user,:new_db_password]
# For example:
# rake miniflix:insert_data['mini0_devlopment','root','root','miniflix_dev','root','root']
