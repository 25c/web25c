class Admin::DashboardController < Admin::AdminController
  
  def index
    @payments = Payment.includes(:user).where(:payment_type => 'payout').find_all_by_state(Payment::State::NEW)
  end
  
  def process_payment
    Payment.find_by_uuid(params[:payment_uuid]).process
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end
  
  def test
    @button = Button.first
    if @button.user == current_user
      @button = Button.all[1]
    end
    @user = current_user
  end
  
end