class HomeController < ApplicationController
  
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :authenticate_if_staging, :only => :paypal_process
  skip_before_filter :verify_authenticity_token, :only => :paypal_process
  skip_before_filter :check_facebook_cookies, :only => :paypal_process
  
  def index
    redirect_to home_dashboard_path if self.current_user
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
    payment = Payment.find_by_uuid(uuid)
    if payment and notify.acknowledge and notify.complete?
      raise Exception.new('Pay-in processing from Paypal failed') unless payment.process 
      return_ok = true
    end
    if return_ok
      render :nothing => true, :status => 200, :content_type => 'text/html'
    else
      render "home/not_found", :status => 404
    end
  end

end
