namespace :test do
  
  desc "Drops and re-creates test database then runs seeds and loads fixtures"
  task :setup do
    env = ENV['RAILS_ENV'] || 'test'
    system("rake db:reset RAILS_ENV=#{env}")
    system("rake db:fixtures:load RAILS_ENV=#{env}")
  end
  
end
