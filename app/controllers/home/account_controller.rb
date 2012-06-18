class Home::AccountController < Home::HomeController
  
  def index
    render :jar
  end
  
  def jar
    @user = current_user
  end
  
  def confirm
  end
  
end