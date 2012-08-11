class HomeController < ApplicationController
  
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :check_facebook_cookies, :only => :paypal_process
  
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
    if Rails.env.production?
      @button = User.find_by_email('rmr@25c.com').buttons[0]
    else
      # dev placeholder for about page button
      @button = Button.first
    end
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
    puts "*********** Calling Paypal process"
    puts request.raw_post
    notify = Paypal::Notification.new(request.raw_post)
    uuid = notify.invoice
    puts notify.inspect
    payment = Payment.includes(:user => :clicks).find_by_uuid(uuid)
    puts "********* Payment object:"
    puts payment.inspect
    if payment and notify.acknowledge
      begin
        puts "*********** trying to save payment"
        # if notify.complete? and payment.amount == notify.amount
        puts "**********"
        puts payment.amount
        puts "**********"
        puts notify.amount
        if notify.complete?
          puts "*********** processing payment"
          payment.process
          payment.user.clicks.each { |click| click.process }
          puts "*********** payment, user and clicks processed"
        else
          puts "*********** Failed to verify Paypal's notification"          
        end
      rescue => e
        raise "Payin processing from Paypal failed"
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
