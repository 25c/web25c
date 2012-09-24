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
  
end
