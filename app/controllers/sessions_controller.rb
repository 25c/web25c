class SessionsController < ApplicationController
  
  def new
    redirect_to_session_redirect_path root_path if self.signed_in?
  end
  
  def failure
    redirect_to sign_in_path, :alert => t("sessions.failure.#{params[:strategy]}")
  end
  
  def create
    user = User.from_omniauth(request.env['omniauth.auth'])
    self.current_user = user
    redirect_to_session_redirect_path root_path
  end
  
  def destroy
    self.current_user = nil
    if not request.referrer.blank? and request.referrer.include? 'blog/header'
      redirect_to request.referrer
    else
      redirect_to root_path
    end
  end
  
end
