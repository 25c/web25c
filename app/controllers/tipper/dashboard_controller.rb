class Tipper::DashboardController < Tipper::TipperController
  # establish_connection "#{Rails.env}_data"

  def index
    
    @user = current_user
    clicks = @user.clicks.where('amount>0').includes(:button => :user).order("created_at DESC").all
        
    @clicks_given = group_clicks(clicks, true, true)
    @clicks_given_total = 0
    @clicks_given.each do |set|
      @clicks_given_total += set[0]
    end
    
    @clicks_unfunded_total = 0
    
    clicks = Click.where(['amount>0 AND receiver_user_id=?', @user.id]).includes(:button, :user).order("created_at DESC").all
    @clicks_received = group_clicks(clicks, false, true)
    @clicks_received_total = 0
    @clicks_received.each do |set|
      @clicks_received_total += set[0]
    end
    
    clicks = Click.where(['amount>0 AND referrer_user_id=?', @user.id]).includes(:button, :user).order("created_at DESC").all
    @clicks_referred = group_clicks(clicks, false, true)
    @clicks_referred_total = 0
    @clicks_referred.each do |set|
      @clicks_referred_total += set[0]
    end
  end
  
  def undo_clicks
    @user = current_user
    @clicks_given = @user.clicks.where(['amount>0 AND state=?', Click::State::GIVEN]).includes(:button => :user).all
  end
  
  def delete_click
    current_user.clicks.find_by_uuid(params[:click_id]).undo
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

end
