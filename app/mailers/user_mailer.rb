class UserMailer < ApplicationMailer
  
  def welcome(user)
    @recipient = user.display_name
    mail :to => user.email, :subject => 'Welcome to 25c.'
  end
  
  def new_invite(invite)
    @user = invite.button.user
    @invite = invite
    mail :to => invite.email, :subject => "25c user #{@user.display_name} is sharing tips with you!"
  end

end