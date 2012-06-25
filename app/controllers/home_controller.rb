class HomeController < ApplicationController
  
  def index
    # redirect_to home_buttons_path if self.current_user
  end
  
  def sign_in
    if request.method == 'POST'
      
      sign_in_successful = false
      has_tip = params.has_key?(:button_id)
      
      # new user
      if params[:user_account] == 'new'
        @new = true
        @user = User.new(params[:user])
        if @user.save
          sign_in_successful = true
          notice = t('users.create.success')
        else
          alert = ""
          @user.errors.full_messages.each do |message|
            if !message.include? "digest"
              alert += message
              alert += ", " if message != @user.errors.full_messages.last
            end
          end     
          @user = nil
        end
      # existing user
      else
        @new = false
        @user = User.find_by_email(params[:user][:email]).try(:authenticate, params[:user][:password])
        if @user
          sign_in_successful = true
        else
          alert = t('home.sign_in.failure')
        end
      end
      if @user
        self.current_user = @user
        # if there is a tip to process, make sure it gets logged
        if has_tip
          button = Button.find_by_uuid(params[:button_id])
          if !button.nil?
            click = @user.clicks.build()
            click.user_id = @user.uuid
            click.publisher_user_id = button.user_id
            if click.save
              notice = t('home.sign_in.click_success')
            else
              alert = t('home.sign_in.click_failure')
            end
          else
            alert = t('home.sign_in.button_not_found')
          end
        end
        # redirect_to_session_redirect_path(home_buttons_path)
        # return
      end
      if alert
        flash[:alert] = alert
      else
        flash[:notice] = notice
      end
    end
    
    # handle page redirecting
    if sign_in_successful
      if has_tip && !alert
        redirect_to_session_redirect_path(confirm_tip_path)
      else
        redirect_to_session_redirect_path(home_buttons_path)
      end
      return
    else
      @user = User.new if !@user
      if has_tip
        redirect_to tip_path(:button_id => params[:button_id], :new => @new)
      end
    end
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
