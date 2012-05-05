class HomeController < ApplicationController
  
  def index
    
  end
  
  def sign_in    
    @user = User.new
    if request.method == 'POST'
      @user = User.find_by_email(params[:user][:email]).try(:authenticate, params[:user][:password])
      if @user
        self.current_user = @user
        redirect_to home_dashboard_path
      end
    end
  end
  
  def sign_out
    self.current_user = nil
    redirect_to root_path
  end
  
end
