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
  
end
