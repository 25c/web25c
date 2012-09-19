class ApplicationMailer < ActionMailer::Base
  
  default from: "no-reply@25c.com"
  layout "mailer"
  
  include ActionView::Helpers::NumberHelper
  helper_method :report_number
  
  class Visits
    extend Garb::Model
    dimensions :hostname
    metrics :visitors
  end
  
  def recipient(user)
    raise Exception.new("Please set a MAILTO=<test email address> environment variable") if Rails.env.development? and ENV['MAILTO'].blank?
    if user.kind_of?(String)
      @recipient = user
    elsif user.display_name.blank?
      @recipient = user.email
    else
      @recipient = "#{user.display_name} <#{user.email}>"
    end
    @recipient = "#{@recipient.parameterize} <#{ENV['MAILTO']}>" if Rails.env.development?
    @recipient
  end
  
  def new_payout_request(user, payment)
    @user = user
    @payment = payment
    mail :to => 'lionel@25c.com', :subject => 'New Payout Request'
  end
  
  def updated_payout_request(user, payment)
    @user = user
    @payment = payment
    mail :to => 'lionel@25c.com', :subject => 'Updated Payout Request'
  end
  
  def daily_report    
    day = Time.now.in_time_zone("Pacific Time (US & Canada)").to_date() - 1
    @day = day
    # Get website visits from Google Analytics
    puts "Getting Google Analytics data..."
    Garb::Session.login("analytics@25c.com", "superlike25")
    profile = Garb::Management::Profile.all.first
    visits_day = sort_visits(Visits.results(profile, 
      :start_date => day, 
      :end_date => day))
    visits_week = sort_visits(Visits.results(profile, 
      :start_date => day.weeks_ago(1) + 1,
      :end_date => day))
    visits_month = sort_visits(Visits.results(profile, 
      :start_date => day.months_ago(1) + 1, 
      :end_date => day))
    visits_total = sort_visits(Visits.results(profile, 
      :start_date => Date.new(2012, 9, 6), 
      :end_date => day))
    @visits = {
      :day => visits_day, 
      :week => visits_week,
      :month => visits_month, 
      :total => visits_total
    }
    
    # Find user totals
    puts "Getting user counts..."
    @users = {
      :day => User.where(:created_at => day..(day + 1)).count,
      :week => User.where(:created_at => (day.weeks_ago(1) + 1)..(day + 1)).count,
      :month => User.where(:created_at => (day.months_ago(1) + 1)..(day + 1)).count,
      :total => User.where("created_at < ?", day + 1).count
    }
    
    # Find click totals
    puts "Getting click counts..."    
    @clicks = {
      :day => Click.where(:created_at => day..(day + 1)).count,
      :week => Click.where(:created_at => (day.weeks_ago(1) + 1)..(day + 1)).count,
      :month => Click.where(:created_at => (day.months_ago(1) + 1)..(day + 1)).count,
      :total => Click.where("created_at < ?", day + 1).count
    }
    
    # Find out how many "active" buttons there are (at least 1 click)
    # TODO: Replace with less DB intensive query!
    puts "Getting active button counts..."
    b_day = 0
    b_week = 0
    b_month = 0
    b_total = 0
    buttons = Button.includes(:clicks).where("created_at < ?", day + 1)
    buttons.each do |button|
      if button.clicks.count > 0
        b_day += 1 if button.created_at > day
        b_week += 1 if button.created_at > day.weeks_ago(1) + 1
        b_month += 1 if button.created_at > day.months_ago(1) + 1
        b_total += 1
      end
    end
    @buttons = { :day => b_day, :week => b_week, :month => b_month, :total => b_total }      

    # Get referrers from latest day
    puts "Getting last day's referrers..."
    clicks = Click.where(:created_at => day..(day + 1))
    @referrers = []
    clicks.each do |click|
      unless click.referrer.blank? or @referrers.include? click.referrer
        @referrers.push(click.referrer)
      end
    end
    
    # Send email to stats distribution list
    puts "Sending daily report email..."
    # mail :to => 'reports@25c.com', :subject => "25c Report - #{day}"
    mail :to => 'lionel@25c.com', :subject => "Testy McTest"
    
    puts "Email sent."
  end
  
  private
  
  def sort_visits(results)
    visits = {}
    results.each do |result|
      if result.hostname == "api.25c.com"
        visits[:api] = result.visitors
      else
        visits[:www] = result.visitors
      end
    end
    return visits
  end
  
  def report_number(number)
    number = number.to_f
    if number > 1000
      number = number_with_precision(number / 1000, :precision => 2, :delimiter => ',') + " K"
    elsif number > 1000000
      number = number_with_precision(number / 1000000, :precision => 2, :delimiter => ',') + " M"
    elsif number > 1000000000
      number = number_with_precision(number / 1000000000, :precision => 2, :delimiter => ',') + " B"
    else
      number.to_i
    end
  end
  
end