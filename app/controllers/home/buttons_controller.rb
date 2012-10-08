class Home::ButtonsController < Home::HomeController

  def index
    redirect_to home_get_button_path
  end
  
  def receive_pledges
    @user = self.current_user
    @button = self.current_user.buttons[0]
  end
  
  def get_button
    @user = self.current_user
    @button = self.current_user.buttons[0]
  end
  
  def show
    @button = self.current_user.buttons.find_by_uuid(params[:id])
    redirect_to home_get_button_path
  end
  
  def update
    @button = self.current_user.buttons.find_by_uuid(params[:id])
    if @button.update_attributes(params[:button])
      flash[:notice] = t('home.buttons.button_updated')
    else
      flash[:alert] = @button.errors.full_messages
    end
    if params.has_key('ajax')
      render :nothing => true, :status => 200, :content_type => 'text/html'
    else
      redirect_to home_get_button_path(@button)
    end
  end

  def update_button
    @user = self.current_user
    @button = @user.buttons[0]
    respond_to do |format|
      if params[:button].include?('picture') and params[:button][:picture].blank?
        @button.picture.destroy
        format.json { render json: true, head: :ok }
      elsif @button.update_attributes(params[:button])
          format.json { render json: true, head: :ok }
          format.html { render template: 'users/upload_picture' } if params[:button].include?('picture')
      else
        format.json { render json: @button.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def choose_pledge_message
    @button = self.current_user.buttons[0]
  end
  
  def share_email
    share_email = params[:share_email]
    share_amount = params[:share_amount].to_i
    if not self.current_user.blank? and not share_email.blank? and share_amount > 0
      # UserMailer.tip_share(self.current_user, share_email, share_amount).deliver
      invites = self.current_user.buttons[0].invites
      existing_invite = invites.select{|invite| invite.email == share_email }
      if existing_invite.nil?
        invites.create(:email => share_email, :share_amount => share_amount)
      else
        existing_invite.update_amount(share_amount)
      end
    end
    respond_to do |format|
      format.json { render json: true, head: :ok }
    end    
  end
  
end
