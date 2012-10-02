class UserMailer < ApplicationMailer
  
  def welcome(user)
    @recipient = user.display_name
    mail :to => user.email, :subject => 'Welcome to 25c.'
  end
  
  def tip_share(user, email, amount)
    @user = user
    @share_amount = amount
    mail :to => email, :subject => "25c user #{@user.display_name} is sharing tips with you!"
  end

end