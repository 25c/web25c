class Publisher::ButtonsController < Publisher::PublisherController

  def index
    redirect_to publisher_get_button_path
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
    redirect_to publisher_get_button_path
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
      redirect_to publisher_get_button_path(@button)
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
    @user = self.current_user
    @button = @user.buttons[0]
    share_email = params[:share_email]
    share_amount = params[:share_amount].to_i
    if not self.current_user.blank? and not share_email.blank? and share_amount > 0
      # UserMailer.tip_share(self.current_user, share_email, share_amount).deliver
      @button.invites.create(:email => share_email, :share_amount => share_amount) if @button.invites.where(:state => Invite::State::OPEN).empty?
    end
    respond_to do |format|
      format.json { render json: { :html => render_to_string(:partial => 'home/buttons/share_revenue', :formats => :html) } }
    end    
  end
  
  def cancel_email
    @user = self.current_user
    @button = @user.buttons[0]
    invite = @button.invites.find_by_uuid(params[:invite_uuid])
    unless invite.nil?
      invite.cancel
    end
    respond_to do |format|
      format.json { render json: { :html => render_to_string(:partial => 'home/buttons/share_revenue', :formats => :html) } }
    end
  end
  
  def stop_share
    @user = self.current_user
    @button = @user.buttons[0]
    @button.update_attribute(:share_users, nil)
    respond_to do |format|
      format.json { render json: { :html => render_to_string(:partial => 'home/buttons/share_revenue', :formats => :html) } }
    end
  end
  
end
