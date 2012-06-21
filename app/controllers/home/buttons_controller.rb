class Home::ButtonsController < Home::HomeController
  
  helper_method :button_uuid
  def button_uuid
    @button_uuid = 12345
  end
  
  def index
    @button = self.current_user.buttons[0]
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
    flash[:notice] = t('home.buttons.button_updated')
    redirect_to home_buttons_path
  end
  
  def edit
    @button = self.current_user.buttons.find_by_uuid(params[:id])
  end
  
  def update
    @button = self.current_user.buttons.find_by_uuid(params[:id])
    if @button.update_attributes(params[:button])
      redirect_to home_button_path(@button)
    else
      render :edit
    end
  end
  
end
