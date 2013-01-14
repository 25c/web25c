class Publisher::DashboardController < Publisher::PublisherController

  def index
    @clicks = self.current_user.clicks_received.order('created_at DESC').page params['page']
    render :partial => 'clicks' if request.xhr?
    @total_received = Integer @clicks.sum { |click| click.amount_free + click.amount_paid }
    
    # TODO: implement CRON job to update fields below for all users
    @payout_estimate = self.current_user.payout_estimate
    @payout_available = self.current_user.payout_available
    
  end
  
  def request_payout
    render :partial => 'form'
  end
  
  def submit_request
    self.current_user.editing = true
    if self.current_user.update_ach_info(params[:user])
      ApplicationMailer.payout_request(self.current_user.id).deliver
      render :partial => 'confirm'
    else
      render :partial => 'form'
    end
  end

end