class UsersController < ApplicationController
  
  before_filter :require_signed_in, :except => [:show, :new, :sign_in, :sign_in_callback, :tip]
  before_filter :check_user_email, :except => [ :user_agremeent, :update, :sign_in, :sign_out, :sign_in_callback, :tip ]

  # GET /users/1
  # GET /users/1.json
  
  def show
    @user = User.find_by_nickname_ci(params[:id])
    if @user
      if Rails.env.development? or request.subdomain == "tip"
        @is_editable = self.current_user == @user unless params[:edit] == 'no'
        @button = @user.buttons[0]
        
        clicks = Click.where(:receiver_user_id => @user.id).includes(:user).order("created_at DESC").find_all_by_state([ 
          Click::State::DEDUCTED, Click::State::FUNDED, Click::State::QUEUED
        ])
        @clicks_received = group_clicks(clicks, false, false)
                
        clicks = @user.clicks.includes(:button => :user).order("created_at DESC").find_all_by_state([
          Click::State::DEDUCTED, Click::State::FUNDED, Click::State::PAID
        ])
        @clicks_given = group_clicks(clicks, true, false)
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @user }
        end
      else
        redirect_to params.merge({:subdomain => 'tip'})
      end
    elsif request.subdomain == "tip"
      redirect_to params.merge({:subdomain => 'www'})
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
        puts @user.errors.inspect
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
    
  def tip
    session[:redirect_path] = request.path unless self.signed_in?
    render :layout => "blank"
  end
    
end
