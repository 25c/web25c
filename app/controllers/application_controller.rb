class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_facebook_cookies
  
  helper_method :signed_in?, :current_user, :url_base
  
  protected
      
  def check_facebook_cookies
    has_signed_in = false
    signed_request = cookies["fbsr_#{FACEBOOK_SETTINGS['app_id']}"]
    unless signed_request.blank?
      oauth = Koala::Facebook::OAuth.new(FACEBOOK_SETTINGS['app_id'], FACEBOOK_SETTINGS['app_secret'])
      @_facebook_session = oauth.parse_signed_request(signed_request)
      if @_facebook_session
        # figure out if we're coming from the "tip" popup login page
        has_tip = request.url.include? '/tip/'
        # if signed in another way, no need to sign in with facebook  
        if self.signed_in?
          return
        # if not, try signing in with an existing facebook-linked account
        else
          self.current_user = User.find_by_facebook_uid(@_facebook_session['user_id']) 
          flash[:notice] = t('application.check_facebook_cookies.sign_in')
        end
        if self.signed_in?
          # verify that the signed in user is linked to the facebook account
          if self.current_user.facebook_uid == @_facebook_session['user_id']
            # if so, refresh access token
            self.current_user.refresh_facebook_access_token(@_facebook_session['code'])
          else
            # uh-oh, shared computer? clear out
            self.current_user = nil
            flash[:alert] = t('application.check_facebook_cookies.failure');
            if has_tip 
              redirect_to tip_path(:button_id => params[:button_id], :referrer => params[:referrer])
              return
            else
              redirect_to sign_in_path
              return
            end
          end
        else
          # register new user
          user = User.new
          user.facebook_uid = @_facebook_session['user_id']
          user.password = SecureRandom.hex
          user.save!
          self.current_user = user
          self.current_user.refresh_facebook_access_token(@_facebook_session['code'])
          # self.current_user.update_profile_from_facebook
          self.current_user.update_profile
        end
        if has_tip
          redirect_to confirm_tip_path(:button_id => params[:button_id], :referrer => params[:referrer])
        elsif self.current_user.is_new
          redirect_to_session_redirect_path(home_buttons_path)
        else
          redirect_to_session_redirect_path(home_dashboard_path)
        end
      end
    end
  end
  
  def require_signed_in
    unless self.signed_in?
      session[:redirect_path] = request.path
      redirect_to sign_in_path
    end
  end
  
  def redirect_to_session_redirect_path(fallback, options = {})
    redirect_path = session.delete(:redirect_path)
    if redirect_path.blank?
      redirect_to fallback, options
    else
      redirect_to redirect_path, options
    end
  end
  
  def require_admin
    redirect_to root_path unless self.signed_in? and self.current_user.is_admin
  end
  
  def signed_in?
    !self.current_user.nil?
  end
  
  def current_user
    @_current_user ||= User.find_by_uuid(REDIS.get(cookies.signed[:'_25c_session']))
  end
  
  def current_user=(user)
    @_current_user = user
    if user.nil?
      cookies.delete(:'_25c_session', :domain => :all)
    else
      # generate a new session key
      generator = UUID.new
      key = generator.generate(:compact)
      # in the next-to-impossible chance we collide with an existing one, carefully check
      previous = REDIS.getset(key, user.uuid)
      while !previous.nil?
        # set back to its original value
        REDIS.set(key, previous)
        # generate new key and try again
        key = generator.generate(:compact)
        previous = REDIS.getset(key, user.uuid)
      end
      cookies.permanent.signed[:'_25c_session'] = {
        :value => key,
        :domain => :all,
      }
    end
  end
  
  def url_base
    return @url_base unless @url_base.nil?
    @url_base = "#{ActionMailer::Base.default_url_options[:host]}"
    port = ActionMailer::Base.default_url_options[:port]
    @url_base = "#{url_base}:#{port}" unless port.blank? or port == 80
    @url_base
  end
  
  def group_clicks_by_count(clicks)
    click_sets = {}
    clicks.each do |click|
      id = click.button.id
      if click_sets[id]
        click_sets[id][0] += 1
      else
        click_set = [1, click]
        click_sets[id] = click_set
      end
    end
    return click_sets.values.sort_by { |set| -set[0]  }
  end
  
  def check_user_agreement
    if signed_in?
      unless self.current_user.has_agreed
        @next_url = request.url
        render "users/user_agreement"
      end
    end
  end
  
end
