class Publisher::DashboardController < Publisher::PublisherController

  def index
    @clicks = self.current_user.clicks_received.order('created_at DESC').page params['page']
  end

end
