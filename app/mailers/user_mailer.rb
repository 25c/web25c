class UserMailer < ApplicationMailer
  
  include Resque::Mailer
  
  def welcome(user_id)
    @user = User.find(user_id)
    mail :to => recipient(@user.email), :subject => 'Welcome to 25c.'
  end
  
  def reset_password(user_id)
    @user = User.find_by_id(user_id)
    @user.editing = true
    @user.reset_password_token = UUID.new.generate(:compact)
    @user.reset_password_sent_at = Time.now.utc
    @user.save!
    mail :to => recipient(@user.email), :subject => t('user_mailer.reset_password.subject')
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


  # >> user_id is the publisher ID and published_stories_id is a pointor to all the stories that need to be published. 
  # >> Else where are those stories?
  def weekly_activities_digest(user_id, published_stories_id)

  end
  
  
  # when a tipper is dislodged from present position to a new position (can be dislodged from displayable area)
  # when a tipper gain position from previous position (may enter displayable area)
  # two types of emails depending if going up or down in position. 
  # show tipper if in displayable area
  # 
  def new_position_in_fanbelt(user_id, click_id, url_title, previous_pos, current_pos)
    @user = User.find(user_id)
    @click = Click.find(click_id)
    @utitle = url_title
    @prevpos = previous_pos
    @curpos = current_pos

    mail :to => recipient(@user.email), :subject => "25c Fan Belt Notification for #{@utitle}"
  end
  
  
  
  # >> when a tipper is dislodged from present position to a new position (can be dislodged from displayable area)
  # >> when a tipper gain position from previous position (may enter displayable area)
  # >> two types of emails depending if going up or down in position. 
  # >> show tipper if in displayable area
  def new_position_in_testimonial(user_id, click_id, url_title, previous_pos, current_position)
    @user = User.find(user_id)
    @click = Click.find(click_id)
    @utitle = url_title
    @prevpos = previous_pos
    @curpos = current_pos

    mail :to => recipient(@user.email), :subject => "25c Testimonial Notification for #{@utitle}"
  end
  
  
  # >> tipper receive confirmation of moderation result
  # >> should only send if comment removed. [APPROVED, DENIED] two response types but only DENIED is used. 
  def comment_moderation(user_id, comment_id, url_title, response)
    @user = User.find(user_id)
    @utitle = url_title
    @comment = Comment.find(comment_id)

    mail :to => recipient(@user.email), :subject => "25c Testimonial Notification for #{@utitle}"
  end 
  
  # >> send an unmoderated comment to the publisher. Everytime a new comment is posted the publisher receive an email
  # >> this function good for real moderation. Maybe disabled in Publisher account. 
  def new_unmoderated_comment(user_id, comment_id, url_title)
    @user = User.find(user_id)
    @utitle = url_title
    @comment = Comment.find(comment_id)

    mail :to => recipient(@user.email), :subject => "New 25c Testimonial Note for #{@utitle}"
  end

  
  # >> Welcome email tailored to widget that the user clicked on
  def new_user_FirstClick(user_id, widget_type, url_title, numclicks)
    @user = User.find(user_id)
    @utitle = url_title
    @wtype = widget_type

    mail :to => recipient(@user.email), :subject => "Welcome to 25c!"
  end
  
  # >> Encouragement email tailored to widget that the user clicked on
  def new_user_SecondClick(user_id, widget_type, url_title, numclicks)
    @user = User.find(user_id)
    @utitle = url_title
    @wtype = widget_type

    mail :to => recipient(@user.email), :subject => "Welcome back to 25c!"
  end
  
  # >> welcome email for publisher
  def new_publisher_welcome(user_id)
    @user = User.find(user_id)

    mail :to => recipient(@user.email), :subject => "25c a New Publisher!"
  end 
  
  
  # >> welcome email for publisher when registering from website (and not from button click)
  def new_user_welcome(user_id)
    @user = User.find(user_id)
    @utitle = url_title

    mail :to => recipient(@user.email), :subject => "Welcome to 25c!"
  end
  
  
  # >> Daily email for the user to complete their profile and payment information
  def profile_completion(user_id)
    @user = User.find(user_id)

    mail :to => recipient(@user.email), :subject => "25c Profile Completion Reminder"
  end 
  
  
  # >> Overview of all tips charged upon reaching treshold 
  def new_invoice(user_id, charges_id)
    @user = User.find(user_id)
    @invoice = Invoice.find(charges_id)

    mail :to => recipient(@user.email), :subject => "New 25c Invoice!"
  end
  
  
  # >> Receive an email when someone promote one of your comment in testimonial widget
  def testimonial_promoted(user_id, tipper_id, comment_id, url_title, promoted_amount)
    @user = User.find(user_id)
    @tipper = User.find(tipper_id)
    @utitle = url_title
    @comment = Comment.find(comment_id)
    @amount = promoted_amount

    mail :to => recipient(@user.email), :subject => "Someone has promoted your note on #{@utitle}"
  end

end
