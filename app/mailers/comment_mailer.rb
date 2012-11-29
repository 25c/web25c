class CommentMailer < ApplicationMailer  
  include Resque::Mailer
  
  # >> when a tipper is dislodged from present position to a new position (can be dislodged from displayable area)
  # >> when a tipper gain position from previous position (may enter displayable area)
  # >> two types of emails depending if going up or down in position. 
  # >> show tipper if in displayable area
  def new_position_in_testimonial(comment_uuid, previous_pos, current_position)
    @comment = Comment.find_by_uuid(comment_uuid)
    @user = @comment.user
    @click = @comment.click
    if @comment.url.title.blank?
      @utitle = @comment.url.url
    else
      @utitle = @comment.url.title
    end
    @prevpos = previous_pos
    @curpos = current_pos

    mail :to => recipient(@user.email), :subject => "25c Testimonial Notification for #{@utitle}"
  end
  
end
