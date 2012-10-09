class Home::DashboardController < Home::HomeController
  # establish_connection "#{Rails.env}_data"

  def index
    
    @user = current_user
    clicks = @user.clicks.includes(:button => :user).order("created_at DESC").find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED, Click::State::QUEUED, Click::State::PAID
    ])
        
    @clicks_given = group_clicks(clicks, true, true)
    @clicks_given_total = 0
    @clicks_given.each do |set|
      @clicks_given_total += set[0]
    end
    
    @clicks_unfunded_total = 0
    clicks.each do |click|
      @clicks_unfunded_total += click.amount if click.state == Click::State::DEDUCTED
    end
    
    clicks = Click.where(:button_id => @user.button_ids).includes(:user).order("created_at DESC").find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED, Click::State::QUEUED
    ])
    @clicks_received = group_clicks(clicks, false, true)
    @clicks_received_total = 0
    @clicks_received.each do |set|
      @clicks_received_total += set[0]
    end
    
    clicks = Click.where(:referrer_user_id => @user.id).includes(:user).order("created_at DESC").find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED, Click::State::QUEUED
    ])
    @clicks_referred = group_clicks(clicks, false, true)
    @clicks_referred_total = 0
    @clicks_referred.each do |set|
      @clicks_referred_total += set[0]
    end
  end
  
  def undo_clicks
    @user = current_user
    @clicks_given = @user.clicks.includes(:button => :user).find_all_by_state(Click::State::DEDUCTED)
  end
  
  def delete_click
    current_user.clicks.find_by_uuid(params[:click_id]).undo
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

end
