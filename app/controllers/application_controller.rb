class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_if_staging
  helper_method :signed_in?, :current_user, :url_base, :mobile_device?
  
  protected
  
  def authenticate_if_staging
    if Rails.env.staging?
      ua = request.env['HTTP_USER_AGENT']      
      authenticate_or_request_with_http_basic do |username, password|
        (username == "user25c" && password == "sup3rl!k3")
      end unless not ua.blank? and (ua.start_with?('facebookexternalhit') or ua.start_with?('twentyfivec'))
    end
  end
  
  def require_signed_in
    unless self.signed_in?
      session[:redirect_path] = request.path
      redirect_to sign_in_path
    end
  end
  
  def require_publisher
    unless self.signed_in? and self.current_user.role == 'publisher'
      session[:redirect_path] = request.path
      redirect_to sign_in_path
    end
  end
  
  def require_tipper
    unless self.signed_in? and self.current_user.role == 'tipper'
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
  
  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end
  
  def group_clicks(clicks, sortByButtonId, splitByState)
    click_sets = {}
    if clicks
      clicks.each do |click|
        
        next if click.button.nil?
        
        if splitByState
          if sortByButtonId
            id = click.button.id.to_s
          else
            id = click.user_id.to_s
          end
          id += click.state == Click::State::GIVEN ? '_0' : '_1'
        else
          if sortByButtonId
            id = click.button.id.to_s
          else
            id = click.user_id.to_s
          end
        end
        if click_sets[id]
          click_sets[id][0] += click.amount
          click_sets[id][1].created_at = click.created_at if click.created_at > click_sets[id][1].created_at
          click_sets[id][1].funded_at = click.funded_at if click.funded_at and (click_sets[id][1].funded_at.nil? or (click.funded_at > click_sets[id][1].funded_at))
        else
          click_set = [click.amount, click]
          click_sets[id] = click_set
        end
      end
    end
    return click_sets.values.sort_by { |set| -set[0]  }
  end
  
  def check_user_email
    if signed_in?
      if self.current_user.email.blank?
        @next_url = request.url
        render "users/choose_email"
      end
    end
  end

end
