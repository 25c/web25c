class Publisher::WidgetsController < Publisher::PublisherController

  def index
    @widgets = self.current_user.buttons.order('created_at DESC')    
    @widget = Button.new
  end
  
  def create
    @user = self.current_user
    @widget = @user.buttons.new(params[:button])
    @widget.widget_type = 'testimonials'
    @invites = []
    
    if @widget.save
      
      unless params[:new_invites].nil? or params[:new_invites].empty?
        params[:new_invites].each do |k,v|
          email = params[:share_emails][k]
          amount = params[:share_amounts][k]
          @button.share_invite(email, amount)
        end
      end
      
      redirect_to publisher_button_path(@widget)
      
    else
      puts @widget.errors.inspect
      @widgets = self.current_user.buttons.order('created_at DESC')    
      render :index
    end
    
  end
  
  def show
    @user = self.current_user
    @widget = @user.buttons.find_by_uuid(params[:id])
    @invites = @widget.invites.where(:state => Invite::State::OPEN)
  end
  
  def update
    
    @widget = current_user.buttons.where(:uuid => params[:id])[0]
    if @widget.update_attributes(params[:button])
      
      unless @widget.share_users.nil?
        new_share_users = []
        unless params[:existing_shares].nil? or params[:existing_shares].empty?
          @widget.share_users.each do |share|
            user = User.find(share.id)
            if not params[:existing_shares].nil? and params[:existing_shares].include?(user.uuid)
              new_share_users.push(share)
            end
          end
        end
        @widget.share_users = new_share_users
        @widget.save!
      end
      
      invites = @widget.invites.where(:state => Invite::State::OPEN)
      
      unless invites.empty?
        invites.each do |invite|
          if params[:existing_invites].nil? or not params[:existing_invites].include?(invite.uuid)
            invite.cancel
          end
        end
      end
      
      unless params[:new_invites].nil? or params[:new_invites].empty?
        params[:new_invites].each do |k,v|
          email = params[:share_emails][k]
          amount = params[:share_amounts][k]
          @widget.share_invite(email, amount)
        end
      end
      
      redirect_to publisher_button_path(@widget), :notice => t('publisher.widgets.update.success')
      
    else
      @user = self.current_user
      @invites = @widget.invites.where(:state => Invite::State::OPEN)
      render :show
    end
  end
  
  def destroy
    Button.find_by_uuid(params[:uuid]).destroy
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end
  
  def share_email
    @user = self.current_user
    @button = @user.buttons[0]
    share_email = params[:share_email]
    share_amount = params[:share_amount].to_i
    if not self.current_user.blank? and not share_email.blank? and share_amount > 0
      # UserMailer.tip_share(self.current_user, share_email, share_amount).deliver
      @button.invites.create(:email => share_email, :share_amount => share_amount) if @button.invites.where(:state => Invite::State::OPEN).empty?
    end
    respond_to do |format|
      format.json { render json: true, head: :ok }
    end    
  end
  
  def cancel_email
    @user = self.current_user
    @button = @user.buttons[0]
    invite = @button.invites.find_by_uuid(params[:invite_uuid])
    unless invite.nil?
      invite.cancel
    end
    respond_to do |format|
      format.json { render json: true, head: :ok }
    end
  end
  
  def stop_share
    @user = self.current_user
    @button = @user.buttons[0]
    @button.update_attribute(:share_users, nil)
    respond_to do |format|
      format.json { render json: true, head: :ok }
    end
  end
  
end
