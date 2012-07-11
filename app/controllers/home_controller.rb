class HomeController < ApplicationController
  
  def index
    # redirect_to home_dashboard_path if self.current_user
    session.delete(:button_id)
    session.delete(:referrer)
    if self.current_user
      @button = self.current_user.buttons[0]
      @is_demo = false
    else
      @button = Button.new({
        :size => "btn-large", 
        :title => "Please super-like my page!",
        :code_type => "javascript"
      })
      @button.uuid = "0123456789abcdef"
      @is_demo = true
    end
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
