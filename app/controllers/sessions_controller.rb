class SessionsController < ApplicationController
  
  def new
    redirect_to_session_redirect_path root_path if self.signed_in?
    @user = User.new
  end
  
  def create
    if request.env['omniauth.auth']
      user = User.from_omniauth(request.env['omniauth.auth'])
      self.current_user = user
      redirect_to_session_redirect_path root_path
    else
      user = User.find_by_email_ci(params[:user][:email])
      if user and user.authenticate(params[:user][:password])
        self.current_user = user
        redirect_to_session_redirect_path root_path
      else
        @user = User.new
        @popup = params[:popup]
        @show_login = true
        @show_login_error = true
        if @popup
          render 'users/tip', :layout => 'blank'
        else
          render :new
        end
      end
    end
  end
  
  def destroy
    self.current_user = nil
    if not request.referrer.blank? and request.referrer.include? 'blog/header'
      redirect_to request.referrer
    else
      redirect_to root_path
    end
  end
  
  def request_password
    user = User.find_by_email(params[:user][:email])
    if user.nil?
      render :json => { :result => 'error', :message => t('sessions.request_password.not_found') }
    else
      UserMailer.reset_password(user.id).deliver
      render :json => { :result => 'success', :message => t('sessions.request_password.email_sent') }
    end
  end
  
  def reset_password
    self.current_user = nil    
    @user = User.find_by_reset_password_token(params[:id])
    if @user and request.method == 'POST'
      @user.password = params['password']
      if @user.save
        @user.update_attribute(:reset_password_token, nil)
        self.current_user = @user
        redirect_to home_dashboard_path, :notice => t('sessions.reset_password.success')
      end
    end
  end
  
end
