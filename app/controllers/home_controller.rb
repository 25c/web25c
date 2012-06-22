class HomeController < ApplicationController
  
  def index
    # redirect_to home_buttons_path if self.current_user
  end
  
  def sign_in
    if request.method == 'POST'
      user = User.find_by_email(params[:user][:email]).try(:authenticate, params[:user][:password])
      if user
        self.current_user = user
        if params.has_key?(:button_id)
          button = Button.find_by_uuid(params[:button_id])
          if !button.nil?
            click = user.clicks.build()
            click.user_id = user.uuid
            click.publisher_user_id = button.user_id
            if click.save
            else
              # puts '*** Click Not Saved ***'
            end
          else
            # puts '*** No Button Found ***'
          end
        end
        redirect_to_session_redirect_path(home_buttons_path)
      else
        flash[:alert] = t('home.sign_in.failure')
      end
    end
    @user = User.new
    @is_new = false
  end
  
  def sign_out
    self.current_user = nil
    redirect_to root_path
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
