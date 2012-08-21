class UsersController < ApplicationController
  
  before_filter :require_signed_in, :except => [ :index, :show, :new, :sign_in, :sign_in_callback, :tip, :confirm_tip]
  before_filter :check_user_agreement, :except => [ :user_agremeent, :update, :sign_in, :sign_out, :sign_in_callback, :tip ]

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find_by_nickname_ci(params[:id])
    
    if @user
      @is_editable = self.current_user == @user
      @button = @user.buttons[0]
      clicks = @user.clicks.includes(:button => :user).order("created_at DESC").find_all_by_state([
        Click::State::DEDUCTED, Click::State::FUNDED, Click::State::PAID
      ])
      @click_sets = group_clicks(clicks, true, false)
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
    else
      render "home/not_found", :status => 404
    end
  end
  
  def profile
    if self.current_user.nickname.blank?
      redirect_to choose_nickname_path
    else
      redirect_to profile_path(current_user.nickname)
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    if self.current_user
      redirect_to_session_redirect_path(home_dashboard_path)
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
    @url = @user.profile_url
  end
  
  def update
    @user = self.current_user
    @user.editing = true
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.json { render json: { :user => @user }, head: :ok }
        if params[:user].include?(:picture)
          @button = @user.buttons[0]
          format.html { render action: 'upload_picture' }
        else
          unless params.include?('async') && params['async'] == "true"
            format.html { redirect_to home_account_path, notice: t('users.update.success') }
          end
        end
      else
        # @user.reload
        @url = @user.profile_url
        unless params.include?('async') && params['async'] == "true"
          format.html { render action: "edit" }
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def upload_picture
    @user = self.current_user
    @button = @user.buttons[0]
    render :layout => "blank"
  end
  
  def choose_nickname
    @user = self.current_user
    @url = @user.profile_url
    if request.method == 'PUT' or request.method == 'POST'
      @user = self.current_user
      @user.editing = true
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to profile_path(:id => @user.nickname), notice: t('users.choose_nickname.success') }
          format.json { render json: true, head: :ok }
        else
          @user.reload
          @url = @user.profile_url
          format.html { redirect_to choose_nickname_path, alert: t('users.choose_nickname.failure')}
          # format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    elsif not @user.nickname.blank?
      redirect_to home_account_path
    end
  end
  
  def sign_in_callback
    auth = request.env['omniauth.auth']
    user = nil
    @redirect_url = sign_in_path
    @is_tip_page = false
    new_account = ''
    case auth['provider']
    when 'twitter'
      user = User.find_by_twitter_uid(auth['uid'])
      if user.nil?
        user = User.new
        new_account = 'twitter'
        user.password = SecureRandom.hex
        user.twitter_uid = auth['uid']
        user.twitter_username = auth['info']['nickname']
        user.twitter_token = auth['credentials']['token']
        user.twitter_token_secret = auth['credentials']['secret']
        unless auth['info']['image'].blank?
          user.picture_url = auth['info']['image'].dup.gsub(/_normal(\.(?i:gif)|\.(?i:jpe?g)|\.(?i:png))$/, "\\1")
        end
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
      if user.picture_file_name.blank? and not auth['info']['image'].blank?
        user.picture_url = auth['info']['image'].dup.gsub(/_normal(\.(?i:gif)|\.(?i:jpe?g)|\.(?i:png))$/, "\\1")
        user.save!
      end
      notice = t('users.sign_in_callback.twitter')
    when 'google_oauth2'
      user = User.find_by_google_uid(auth['uid'])
      if user.nil?
        user = User.new
        new_account = 'google'
        user.password = SecureRandom.hex
        user.google_uid = auth['uid']
        user.google_token = auth['credentials']['token']
        user.google_refresh_token = auth['credentials']['refresh_token']
        user.first_name = auth['info']['first_name']
        user.last_name = auth['info']['last_name']
        user.picture_url = auth['info']['image'] unless auth['info']['image'].blank?
        user.save!
        begin
          user.email = auth['info']['email']
          user.save!
        rescue
          user.reload
        end
        begin
          user.nickname = auth['info']['email'].split('@')[0]
          user.save!
        rescue
          user.reload
        end
      elsif user.google_token.blank? or user.google_refresh_token.blank?
        if auth['credentials']['refresh_token'].blank?
          @redirect_url = '/auth/google_oauth2?approval_prompt=force'
          # return
        end
        user.google_token = auth['credentials']['token']
        user.google_refresh_token = auth['credentials']['refresh_token']        
        user.save!
      end
      if user.picture_file_name.blank? and not auth['info']['image'].blank?
        user.picture_url = auth['info']['image']
        user.save!
      end
      notice = t('users.sign_in_callback.google')
    end
    unless user.nil?
      if session.delete(:has_seen_agreement_text)
        user.has_agreed = true
        user.save!
      end
      self.current_user = user
      user.update_profile if user.picture_file_name.blank? and not user.picture_url.blank?
      
      unless params[:state].blank?
        state = params[:state].split('|')
        button_id = state[0]
        referrer = state[1]
        source = state[2]
      end
      
      if button_id
        if new_account.blank?
          Click.enqueue(self.current_user, button_id, referrer, request, cookies)
        end
        @redirect_url = tip_path(
          :button_id => button_id,
          :referrer => referrer,
          :source => source,
          :new_account => new_account
          )
        @is_tip_page = true
      else
        @redirect_url = home_dashboard_path
        flash[:notice] = notice
      end
    end
    render :layout => "blank"
  end
  
  def sign_in
    session[:has_seen_agreement_text] = true
    if self.current_user
      redirect_to_session_redirect_path(home_dashboard_path)
    end
  end
  
  def sign_out
    self.current_user = nil
    if not request.referrer.blank? and request.referrer.include? 'blog/header'
      redirect_to request.referrer
    else
      redirect_to root_path
    end
  end
  
  def tip
    session[:has_seen_agreement_text] = true
    redirect_path = session.delete(:redirect_path)
    @referrer = params[:referrer]
    # @button_id = params[:button_id]
    @new_account = params[:new_account]
    # @new_account = 'google'
    @source = params[:source]
    @user = self.current_user
    @button = Button.find_by_uuid(params[:button_id])
    render :layout => "blank"
  end
    
end
