class Home::ButtonsController < Home::HomeController
  
  def index
    @is_new = self.current_user.is_new
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
    redirect_to home_buttons_path(@button)
  end
  
  def dismiss_welcome
    @user = self.current_user
    @user.editing = true
    self.current_user.is_new = false
    self.current_user.save
    @user.editing = false
    render :nothing => true
  end
  
end
