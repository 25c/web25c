class Home::DashboardController < Home::HomeController
  
  def index
    @user = current_user
    @clicks_given = @user.clicks.includes(:button => :user).order("created_at DESC")
    # LJ: placeholder until we know what type of clicks to display in dashboard
    @has_new_clicks = @clicks_given.each.any? { |s| s[:state] == 0 }
    @clicks_received = Click.where(:button_id => @user.button_ids).includes(:user).order("created_at DESC")
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
