namespace :test do
  
  desc "Drops and re-creates test database then runs seeds and loads fixtures"
  task :setup do
    env = ENV['RAILS_ENV'] || 'test'
    system("rake db:reset RAILS_ENV=#{env}")
    system("rake db:fixtures:load RAILS_ENV=#{env}")
  end
  
end

# monkey-patch the db:test:purge task so that it can run on Heroku, where
# we don't have DROP/CREATE DATABASE privileges.  Instead, we just dump
# the schema itself
Rake::Task['db:test:purge'].clear
namespace :db do
  namespace :test do
    task :purge => :environment do
      config = ActiveRecord::Base.configurations['test']
      ActiveRecord::Base.clear_active_connections!
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection.execute 'DROP SCHEMA public CASCADE'
      ActiveRecord::Base.connection.execute 'CREATE SCHEMA public'
    end
  end
end
