class Tipper::DashboardController < Tipper::TipperController

  def index
    @clicks = self.current_user.clicks.where('amount>0').order('created_at DESC').page params[:page]
    render :partial => 'clicks' if request.xhr?
  end
  
  def cancel_click
    if self.current_user.clicks.find_by_uuid(params[:uuid]).cancel
      if request.xhr?
        head :ok
      else
        redirect_to tipper_dashboard_path, :notice => t('tipper.dashbaord.cancel_click.success')
      end
    else
      if request.xhr?
        render :text => t('tipper.dashboard.cancel_click.failure'), :status => :internal_server_error
      else
        redirect_to tipper_dashboard_path, :alert => t('tipper.dashboard.cancel_click.failure')
      end
    end
  end

end
