class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@25c.com"
  layout "mailer"
  
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
  
end