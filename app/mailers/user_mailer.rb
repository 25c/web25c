class UserMailer < ApplicationMailer
  
  def welcome(user)
    @recipient = user.display_name
    mail :to => user.email, :subject => 'Welcome to 25c.'
  end
    
end