class UserMailer < ApplicationMailer
  
  include Resque::Mailer
  
  def welcome(user_id)
    @user = User.find(user_id)
    mail :to => recipient(@user.email), :subject => 'Welcome to 25c.'
  end
  
  def new_invite(invite_id)
    @invite = Invite.find(invite_id)
    @user = @invite.button.user
    mail :to => recipient(@invite.email), :subject => t('user_mailer.new_invite.subject', :user => @user.display_name)
  end
  
  # remind the user to fund their tips
  def fund_reminder(user_id)
    @user = User.find_by_id(user_id)
    mail :to => recipient(@user.email), :subject => t('user_mailer.fund_reminder.subject')
  end
  
  # tell sharer that their button tips are now being shared
  def share_confirm(sharer_id, receiver_id, share_amount)
    @receiver = User.find(receiver_id)
    @sharer = User.find(sharer_id)
    @share_amount = share_amount
    mail :to => recipient(@sharer.email), :subject => "#{@receiver.display_name} has accepted your shared tips"
  end
  
  # tell sharee that they are now receiving shared tips
  def share_welcome(sharer_id, receiver_id, share_amount)
    @receiver = User.find(receiver_id)
    @sharer = User.find(sharer_id)
    @share_amount = share_amount
    mail :to => recipient(@receiver.email), :subject => "You are set up to receive tips shared by #{@sharer.display_name}"
  end

end
