class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :signed_in?, :current_user
  
  private
  
  def signed_in?
    !current_user.nil?
  end
  
  def current_user
    @_current_user ||= User.find_by_uuid(session[:user])
  end
  
  def current_user=(user)
    @_current_user = user
    if user.nil?
      session.delete(:user)
    else
      session[:user] = user.uuid
    end
  end
  
end
