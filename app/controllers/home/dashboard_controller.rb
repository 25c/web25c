class Home::DashboardController < Home::HomeController

  def index
    @user = current_user
    clicks = @user.clicks.includes(:button => :user).order("created_at DESC").find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED, Click::State::PAID
    ])
    
    @clicks_given = group_clicks(clicks, true, true)
    @clicks_given_total = clicks.length
    @clicks_unfunded_total = clicks.count{ |click| click.state == Click::State::DEDUCTED }

    clicks = Click.where(:button_id => @user.button_ids).includes(:user).order("created_at DESC").find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED, Click::State::PAID
    ])
    @clicks_received = group_clicks(clicks, false, true)
    @clicks_received_total = clicks.length
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
