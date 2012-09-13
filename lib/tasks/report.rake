namespace :admin do
  desc "Send a daily email report of application activity."
  task :daily_report => :environment do    
    ApplicationMailer.daily_report.deliver
  end
end