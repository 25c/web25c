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
    @url = get_profile_url(@user)
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
        @url = get_profile_url(@user)
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
    @url = get_profile_url(@user)
    if request.method == 'PUT' or request.method == 'POST'
      @user = self.current_user
      @user.editing = true
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to profile_path(:id => @user.nickname), notice: t('users.choose_nickname.success') }
          format.json { render json: true, head: :ok }
        else
          @user.reload
          @url = get_profile_url(@user)
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
      state = Rack::Utils.parse_query(params[:state])
      if state['button_id']
        Click.enqueue(self.current_user, state['button_id'], state['referrer'], request, cookies)
        @redirect_url = tip_path(
          :button_id => state['button_id'], 
          :referrer => state['referrer'],
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
              if not message.include? "digest"
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
        if has_tip and not alert
          Click.enqueue(self.current_user, params[:button_id], params[:referrer], request, cookies)

          redirect_to confirm_tip_path(:button_id => params[:button_id], :referrer => params[:referrer])
        else
          redirect_to_session_redirect_path(home_dashboard_path)
        end
        return
      else
        @user = User.new if not @user
        if has_tip
          redirect_to tip_path(:button_id => params[:button_id], :referrer => params[:referrer], :new => @new)
        end
      end
    # not a post request
    else
      session[:has_seen_agreement_text] = true
      if self.current_user
        redirect_to_session_redirect_path(home_dashboard_path)
      else
        @user = User.new
      end
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
    
    # LJ: DEBUG
    @new_account = ''
    
    @user = self.current_user
    @button = Button.find_by_uuid(params[:button_id])
    render :layout => "blank"
  end
  
  private
  
  def get_profile_url(user)
    url = 'http://' + request.domain
    url += ':3000' if request.domain == 'localhost'
    url += '/'
    if user and not user.nickname.blank?
      url += user.nickname
    else
      url += t('users.choose_nickname.nickname')
    end
    return url
  end
    
end
