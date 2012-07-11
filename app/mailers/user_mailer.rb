class UserMailer < ApplicationMailer
  
  def welcome(user)
    mail :to => recipient(user), :subject => 'test'
  end
  
end
