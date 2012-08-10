class HomeController < ApplicationController
  
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

end
