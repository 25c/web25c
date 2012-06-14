class HomeController < ApplicationController
  
  def index
    # redirect_to home_buttons_path if self.current_user
  end
  
  def sign_in
    if request.method == 'POST'
      user = User.find_by_email(params[:user][:email]).try(:authenticate, params[:user][:password])
      if user
        self.current_user = user
        redirect_to_session_redirect_path(home_buttons_path)
      else
        flash[:alert] = t('home.sign_in.failure')
      end
    end
    @user = User.new
  end
  
  def sign_out
    self.current_user = nil
    redirect_to root_path
  end
  
end
