class HomeController < ApplicationController
  
  def index
    redirect_to home_buttons_path if self.current_user
  end
    
  # static pages
  def privacy
  end
  
  def faq
  end
  
  def terms
  end
  
  def contact
  end
  
end
