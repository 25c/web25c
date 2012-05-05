class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_facebook_cookies
  
  helper_method :signed_in?, :current_user
  
  protected
      
  def check_facebook_cookies
    signed_request = cookies["fbsr_#{FACEBOOK_SETTINGS['app_id']}"]
    unless signed_request.blank?
      oauth = Koala::Facebook::OAuth.new(FACEBOOK_SETTINGS['app_id'], FACEBOOK_SETTINGS['app_secret'])
      @_facebook_session = oauth.parse_signed_request(signed_request)
      if @_facebook_session
        # if not signed in, try auto-sign-in by facebook uid        
        unless self.signed_in?
          self.current_user = User.find_by_facebook_uid(@_facebook_session['user_id']) 
          flash[:notice] = t('application.check_facebook_cookies.sign_in')
        end
        if self.signed_in?
          # verify that the signed in user is linked to the facebok account
          if self.current_user.facebook_uid == @_facebook_session['user_id']
            # if so, refresh access token
            self.current_user.refresh_facebook_access_token(@_facebook_session['code'])
          else
            # uh-oh, shared computer? clear out
            self.current_user = nil
            redirect_to root_path
          end
        else
          # register new user
          user = User.new
          user.facebook_uid = @_facebook_session['user_id']
          user.facebook_registration = true
          user.password = SecureRandom.hex
          user.save!
          self.current_user = user
          self.current_user.refresh_facebook_access_token(@_facebook_session['code'])
          redirect_to home_dashboard_path, :notice => t('application.check_facebook_cookies.sign_up')
        end
      end
    end
  end
  
  def require_signed_in
    redirect_to sign_in_path unless self.signed_in?
  end
  
  def signed_in?
    !self.current_user.nil?
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
