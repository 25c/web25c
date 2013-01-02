class Publisher::DashboardController < Publisher::PublisherController

  def index
    @clicks = self.current_user.clicks_received.order('created_at DESC').page params['page']
    render :partial => 'clicks' if request.xhr?
  end

end
