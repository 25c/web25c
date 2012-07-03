class Home::DashboardController < Home::HomeController
  
  def index
    @user = current_user
    @clicks_given = @user.clicks.includes(:button => :user).order("created_at DESC")    
    @clicks_received = Click.where(:button_id => @user.button_ids).includes(:user).order("created_at DESC")
  end
  
  def delete_click
    current_user.clicks.find_by_uuid(params[:click_id]).destroy
    render :nothing => true
  end
  
end
