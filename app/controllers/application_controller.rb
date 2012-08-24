class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_facebook_cookies
  helper_method :signed_in?, :current_user, :url_base
  
  protected
      
  def check_facebook_cookies
    has_signed_in = false
    signed_request = cookies["fbsr_#{FACEBOOK_SETTINGS['app_id']}"]
    new_account = ''
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
              redirect_to tip_path(
                :button_id => params[:button_id], 
                :referrer => params[:referrer],
                :source => params[:source]
              )
              return
            else
              if not request.referrer.blank? and request.referrer.include? 'blog/header'
                redirect_to request.referrer
              else
                redirect_to sign_in_path
              end
              return
            end
          end
        else
          # register new user
          user = User.new
          new_account = 'facebook'
          user.facebook_uid = @_facebook_session['user_id']
          user.password = SecureRandom.hex
          user.save!
          self.current_user = user
          self.current_user.refresh_facebook_access_token(@_facebook_session['code'])
          # self.current_user.update_profile_from_facebook
          self.current_user.update_profile
        end
        current_user.has_agreed = true
        current_user.save!
        if has_tip
          Click.enqueue(self.current_user, params[:button_id], params[:referrer], request, cookies)
          redirect_to tip_path(
            :button_id => params[:button_id], 
            :referrer => params[:referrer],
            :source => params[:source],
            :new_account => new_account
          )
        else
          if not request.referrer.blank? and request.referrer.include? 'blog/header'
            redirect_to request.referrer
          else
            if current_user.has_seen_receive_page
              redirect_to_session_redirect_path(home_dashboard_path)
            else
              redirect_to_session_redirect_path(home_receive_pledges_path)
            end
          end
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
      while REDIS.setnx(key, user.uuid) == 0
        # generate new key and try again
        key = generator.generate(:compact)
      end
      # set matching expiration in redis and on cookie
      REDIS.expire(key, 2.week.to_i)
      cookies.signed[:'_25c_session'] = {
        :value => key,
        :domain => :all,
        :expires => 2.week.from_now
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
  
  def group_clicks(clicks, sortByButtonId, splitByState)
    click_sets = {}
    if clicks
      clicks.each do |click|
        if splitByState
          if sortByButtonId
            id = click.button.id.to_s
          else
            id = click.user_id.to_s
          end
          id += click.state == Click::State::DEDUCTED ? '_0' : '_1'
        else
          if sortByButtonId
            id = click.button.id.to_s
          else
            id = click.user_id.to_s
          end
        end
        if click_sets[id]
          click_sets[id][0] += 1
          if click.created_at > click_sets[id][1].created_at
            click_sets[id][1].created_at = click.created_at
          end
        else
          click_set = [1, click]
          click_sets[id] = click_set
        end
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
