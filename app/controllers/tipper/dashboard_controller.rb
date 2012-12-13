class Tipper::DashboardController < Tipper::TipperController
  # establish_connection "#{Rails.env}_data"

  def index
    @clicks = self.current_user.clicks.where('amount>0').page params[:page]
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
