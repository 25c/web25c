class Home::ButtonsController < Home::HomeController

  def index
    @user = self.current_user
    @button = self.current_user.buttons[0]
    @is_demo = false
  end
  
  def new
    @button = self.current_user.buttons.build
  end
  
  def create
    @button = self.current_user.buttons.build(params[:button])
    if @button.save
      redirect_to home_buttons_path
    else
      render :new
    end
  end
  
  def show
    @button = self.current_user.buttons.find_by_uuid(params[:id])
    redirect_to home_buttons_path
  end
  
  def edit
    @button = self.current_user.buttons.find_by_uuid(params[:id])
  end
  
  def update
    @button = self.current_user.buttons.find_by_uuid(params[:id])
    if @button.update_attributes(params[:button])
      flash[:notice] = t('home.buttons.button_updated')
    else
      flash[:alert] = @button.errors.full_messages
    end
    if params.has_key('ajax')
      render :nothing => true
    else
      redirect_to home_buttons_path(@button)
    end
  end
  
  def update_button_picture
    @user = self.current_user
    @button = @user.buttons[0]
    respond_to do |format|
      if @button.update_attributes(params[:button])
        format.html { render template: 'users/upload_picture' }
        format.json { render json: true, head: :ok }
      else
        format.json { render json: @button.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_button
    button = self.current_user.buttons[0]
    if params[:button].has_key?('picture') and params[:button][:key].blank?
      button.picture.destroy
    else
      button.update_attributes!(params[:button])
    end
    render :nothing => true
  end
  
end
