class UsersController < ApplicationController
  before_filter :require_signed_in, :only => [ :edit, :update, :edit_profile, :update_profile ]
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find_by_nickname_ci(params[:id])
    @is_editable = false
    @user.first_name = @user.email if @user.first_name.blank?
    @user.about = t('users.show.blank_about') if @user.about.blank?
    @button = @user.buttons[0]
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    if self.current_user
      if self.current_user.is_new
        redirect_to_session_redirect_path(home_buttons_path)
      else
        redirect_to_session_redirect_path(home_dashboard_path)
      end
    else    
      @user = User.new
      @new = true
      respond_to do |format|
        format.html { render action: "sign_in" }
        format.json { render json: @user }
      end
    end
  end

  # GET /users/1/edit
  def edit
    @user = self.current_user
    if @user.nickname
      @url = 'http://' + request.domain
      @url += ':3000' if request.domain == 'localhost'
      @url += '/' + @user.nickname
    else
      @url = 'http://25c.com/example'
    end
  end
  
  def update
    @user = self.current_user
    @user.editing = true
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to home_account_path, notice: t('users.update.success') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit_profile
    @user = self.current_user
    @button = @user.buttons[0]
    if @user.nickname
      @url = 'http://' + request.domain
      @url += ':3000' if request.domain == 'localhost'
      @url +=  '/' + @user.nickname
    else
      @url = ''
    end
    @is_editable = true
  end
  
  def update_profile
    @user = self.current_user
    @user.editing = true
    respond_to do |format|
      if @user.update_attributes(params[:user])
        if params[:user].include?(:picture)
          format.html { render action: 'upload_image', :url => @user.picture }
          format.json { render json: true, head: :ok }
        else
          format.json { render json: true, head: :ok }
        end
      else
        format.html { render action: "edit_profile" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def upload_image
    @user = self.current_user
    render :layout => "blank"
  end
  
  def sign_in_callback
    auth = request.env['omniauth.auth']
    user = nil
    case auth['provider']
    when 'twitter'
      user = User.find_by_twitter_uid(auth['uid'])
      if user.nil?
        user = User.new
        user.password = SecureRandom.hex
        user.twitter_uid = auth['uid']
        user.twitter_username = auth['info']['nickname']
        user.twitter_token = auth['credentials']['token']
        user.twitter_token_secret = auth['credentials']['secret']
        unless auth['info']['name'].blank?
          names = auth['info']['name'].strip.split(" ")
          user.first_name = names[0]
          user.last_name = names[1..-1].join(" ") if names.length > 1
        end
        user.save!
        begin
          user.nickname = auth['info']['nickname']
          user.save!
        rescue
          user.reload
        end
      elsif user.twitter_token.blank? or user.twitter_token_secret.blank?
        user.twitter_token = auth['credentials']['token']
        user.twitter_token_secret = auth['credentials']['secret']
        user.save!
      end
      notice = t('users.sign_in_callback.twitter')
    when 'google_oauth2'
      user = User.find_by_google_uid(auth['uid'])
      if user.nil?
        user = User.new
        user.password = SecureRandom.hex
        user.google_uid = auth['uid']
        user.google_token = auth['credentials']['token']
        user.google_refresh_token = auth['credentials']['refresh_token']
        user.first_name = auth['info']['first_name']
        user.last_name = auth['info']['last_name']
        user.save!
        begin
          user.email = auth['info']['email']
          user.save!
        rescue
          user.reload
        end
      elsif user.google_token.blank? or user.google_refresh_token.blank?
        if auth['credentials']['refresh_token'].blank?
          redirect_to '/auth/google_oauth2?approval_prompt=force'
          return
        end
        user.google_token = auth['credentials']['token']
        user.google_refresh_token = auth['credentials']['refresh_token']
        user.save!
      end
      notice = t('users.sign_in_callback.google')
    end
    if user.nil?
      redirect_to sign_in_path
    else
      self.current_user = user
      if session[:button_id]
        redirect_to confirm_tip_path(:button_id => session.delete(:button_id), 
          :referrer => session.delete(:referrer))
      else
        redirect_to home_buttons_path, :notice => notice
      end
    end
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
          if @user.errors
            alert = ""
            @user.errors.full_messages.uniq.each do |message|
              if !message.include? "digest"
                alert += message
                alert += ", " if message != @user.errors.full_messages.last
              end
            end
            alert += "."
          else
            alert = t('users.create.failure')
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
          alert = t('users.sign_in.failure')
        end
      end
      if @user
        self.current_user = @user
        # if there is a tip to process, make sure it gets logged
      end
      if alert
        flash[:alert] = alert
      else
        flash[:notice] = notice
      end
      # handle page redirecting
      if sign_in_successful
        if has_tip && !alert
          redirect_to confirm_tip_path(:button_id => params[:button_id], :referrer => params[:referrer])
        elsif @user.is_new
          redirect_to_session_redirect_path(home_buttons_path)
        else
          redirect_to_session_redirect_path(home_dashboard_path)
        end
        return
      else
        @user = User.new if !@user
        if has_tip
          redirect_to tip_path(:button_id => params[:button_id], :referrer => params[:referrer], :new => @new)
        end
      end
    # not a post request
    else
      session.delete(:button_id)
      session.delete(:referrer)
      if self.current_user
        if self.current_user.is_new
          redirect_to_session_redirect_path(home_buttons_path)
        else
          redirect_to_session_redirect_path(home_dashboard_path)
        end
      else
        @user = User.new
      end
    end
  end
  
  def sign_out
    self.current_user = nil
    redirect_to root_path
  end
  
  def tip
    if self.current_user
      redirect_to confirm_tip_path(:button_id => params[:button_id], :referrer => params[:referrer])
    else
      @user = User.new
      @new = params[:new] ? params[:new] == "true" : true
      @button_id = params[:button_id]
      @referrer = params[:referrer]
      session[:button_id] = @button_id
      session[:referrer] = @referrer
      render :layout => "blank"
    end
  end
  
  def confirm_tip
    if self.current_user
      @user = self.current_user
    else
      flash[:alert] = t('users.sign_in.failure')
      redirect_to tip_path(:button_id => params[:button_id], :referrer => params[:referrer])
      return
    end
    button = Button.find_by_uuid(params[:button_id])
    if !button.nil?
      click = @user.clicks.build()
      click.uuid = UUID.new.generate
      click.user_id = @user.id
      click.button_id = button.id
      click.referrer = params[:referrer]
      if click.save
        notice = t('users.sign_in.click_success')
      else
        alert = t('users.sign_in.click_failure')
      end
    else
      alert = t('users.sign_in.button_not_found')
    end
    if alert
      flash.now[:alert] = alert
    else
      flash.now[:notice] = notice
    end
    render :layout => "blank"
  end
    
end
