class HomeController < ApplicationController
  
  include ActiveMerchant::Billing::Integrations
  
  skip_before_filter :show_placeholder_if_production, :only => [ :coming_soon, :demo ]
  
  def coming_soon
  end
  
  def demo
    user = User.find_by_email('dev@25c.com')
    if user and user.buttons[0]
      @uuid = User.find_by_email('dev@25c.com').buttons[0].uuid
    end
  end
  
  def index
    if self.current_user
      redirect_to publisher_dashboard_path if self.current_user.role == 'publisher'
      redirect_to tipper_dashboard_path if self.current_user.role == 'tipper'
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

  end
  
  def not_found
    render "not_found", :status => 404
  end
    
  def blog_header
    render :layout => "blank"
  end
  
  def blog_footer
    render :layout => "blank"
  end

end
