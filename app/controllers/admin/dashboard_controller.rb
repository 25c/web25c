class Admin::DashboardController < Admin::AdminController
  
  def index
    @payments = Payment.includes(:user).where(:payment_type => 'payout').find_all_by_state(Payment::State::NEW)
  end
  
  def process_payment
    Payment.find_by_uuid(params[:payment_uuid]).process
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end
  
  def test
    @user = current_user
    @belt = Button.where("widget_type = ? and user_id != ?", "fan_belt", current_user.id).first
    @testimonials = Button.where("widget_type = ? and user_id != ?", "testimonials", current_user.id).first
  end
  
end