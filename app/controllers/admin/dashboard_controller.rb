class Admin::DashboardController < Admin::AdminController
  
  def index
    @payments = Payment.includes(:user).find_all_by_state(Payment::State::NEW)
  end
  
  def process_payment
    Payment.find_by_uuid(params[:payment_uuid]).process
    render :nothing => true
  end
  
end
