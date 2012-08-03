class Home::DashboardController < Home::HomeController

  def index
    @user = current_user
    clicks = @user.clicks.includes(:button => :user).find_all_by_state([ 1, 2, 3, 4 ])
    # LJ: placeholder until we know what type of clicks to display in dashboard
    # @has_new_clicks = clicks.each.any? { |s| s[:state] == 0 }
    @clicks_given = group_clicks_by_count(clicks)
    @clicks_given_total = clicks.length

    clicks = Click.where(:button_id => @user.button_ids).includes(:user).find_all_by_state([ 1, 2, 3, 4 ])
    @clicks_received = group_clicks_by_count(clicks)
    @clicks_received_total = clicks.length
    
    puts @clicks_received.inspect
  end
  
  def undo_clicks
    @user = current_user
    @clicks_given = @user.clicks.includes(:button => :user).find_all_by_state([ 1, 2 ])
  end
  
  def delete_click
    current_user.clicks.find_by_uuid(params[:click_id]).undo
    render :nothing => true
  end
  
  def process_clicks
    # TODO: dispatch a background job that will do this
    current_user.clicks.where(:state => Click::State::FUNDED).find_each do |click|
      click.process
    end
    render :nothing => true
  end

end
