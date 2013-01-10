class Publisher::DashboardController < Publisher::PublisherController

  def index
    @clicks = self.current_user.clicks_received.order('created_at DESC').page params['page']
    render :partial => 'clicks' if request.xhr?
    @total_received = Integer @clicks.sum { |click| click.amount_free + click.amount_paid }
  end

end
