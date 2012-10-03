class HomeController < ApplicationController
  
  # before_filter :authenticate, :except => :paypal_process
  
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :check_facebook_cookies, :only => :paypal_process
  
  def authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        (username == "user25c" && password == "sup3rl!k3") || (username == "guest" && password == "123456")
      end 
    end
  end
  
  def index
    # redirect_to home_dashboard_path if self.current_user
    session.delete(:button_id)
    session.delete(:referrer)
    # session.delete(:has_seen_agreement_text)
    user = self.current_user
    
    if user and not user.nickname.blank?
      @profile_path = profile_path(user.nickname)
    else
      @profile_path = choose_nickname_path
    end
  end

  # static pages
  def privacy
  end

  def faq
  end

  def terms
  end
  
  def about
    user = User.find_by_email('rmr@25c.com')
    unless Rails.env.production?
      # dev / staging - if no rmr, then find someone else to use for the button
      user = User.find_by_email('dev+staging@25c.com') if user.nil?
      user = User.first if user.nil?
    end
    @button = user.buttons[0]
    @profile_url = user.profile_url
  end
  
  def not_found
    render "not_found", :status => 404
  end
  
  def fb_share_callback
    render :layout => "blank"
  end
  
  def blog_header
    render :layout => "blank"
  end
  
  def blog_footer
    render :layout => "blank"
  end
  
  def paypal_process
    return_ok = false
    notify = Paypal::Notification.new(request.raw_post)
    uuid = notify.invoice
    payment = Payment.includes(:user => :clicks).find_by_uuid(uuid)
    if payment and notify.acknowledge
      begin
        if notify.complete?
          payment.process
          payment.user.clicks.each { |click| click.process }
        end
      rescue => e
        raise "Pay-in processing from Paypal failed"
      end
      return_ok = true
    end
    if return_ok
      render :nothing => true, :status => 200, :content_type => 'text/html'
    else
      render "home/not_found", :status => 404
    end
  end

end
