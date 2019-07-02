namespace :devel do
    desc 'Find file where Uglifier raise error on assets precompile'
    task debug_precompile_errors: :environment do

    JS_PATH = "app/assets/javascripts/**/*.js"; 
    Dir[JS_PATH].each do |file_name|
      puts "\n#{file_name}"
      puts Uglifier.compile(File.read(file_name))
    end
  end
end