class UserMailer < ApplicationMailer
  
  include Resque::Mailer
  
  def welcome(user_id)
    @user = User.find(user_id)
    mail :to => @user.email, :subject => 'Welcome to 25c.'
  end
  
  def new_invite(invite_id)
    @invite = Invite.find(invite_id)
    @user = @invite.button.user
    mail :to => @invite.email, :subject => "25c user #{@user.display_name} is sharing tips with you!"
  end
  
  # tell sharer that their button tips are now being shared
  def share_confirm(sharer_id, receiver_id, share_amount)
    @receiver = User.find(receiver_id)
    @sharer = User.find(sharer_id)
    @share_amount = share_amount
    mail :to => @sharer.email, :subject => "#{@receiver.display_name} has accepted your shared tips"
  end
  
  # tell sharee that they are now receiving shared tips
  def share_welcome(sharer_id, receiver_id, share_amount)
    @receiver = User.find(receiver_id)
    @sharer = User.find(sharer_id)
    @share_amount = share_amount
    mail :to => @receiver.email, :subject => "You are set up to receive tips shared by #{@sharer.display_name}"
  end

end