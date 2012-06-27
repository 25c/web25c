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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @new = true

    respond_to do |format|
      format.html { render '/home/sign_in' }
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = self.current_user
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
  end
  
  def update_profile
    @user = self.current_user
    @user.editing = true
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to home_profile_path, notice: t('users.update_profile.success') }
        format.json { head :no_content }
      else
        format.html { render action: "edit_profile" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
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
        redirect_to confirm_tip_path(:button_id => params[:button_id])
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
  
  def tip
    @user = User.new
    @new = params[:new] ? params[:new] == "true" : true
    @button_id = params[:button_id]
    render :layout => "blank"
  end
  
  def confirm_tip
    if self.current_user
      @user = self.current_user
    else
      flash[:alert] = t('home.sign_in.failure')
      redirect_to tip_path(:button_id => params[:button_id])
      return
    end
    button = Button.find_by_uuid(params[:button_id])
    if !button.nil?
      click = @user.clicks.build()
      click.uuid = UUID.new.generate
      click.user_id = @user.id
      click.button_id = button.id
      if click.save
        notice = t('home.sign_in.click_success')
      else
        alert = t('home.sign_in.click_failure')
      end
    else
      alert = t('home.sign_in.button_not_found')
    end
    if alert
      flash.now[:alert] = alert
    else
      flash.now[:notice] = notice
    end
    render :layout => "blank"
  end
    
end
