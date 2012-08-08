class Home::AccountController < Home::HomeController
  
  def index
    render :payment
  end
  
  def payment
    @user = current_user
  end
  
  def payment_success
    @user = current_user
    if @user.balance <= -40
      @user.balance = @user.balance + 40
      # TODO: dispatch a background job that will do this
      current_user.clicks.where(:state => Click::State::DEDUCTED).find_each do |click|
        click.process
      end
    end
  end
  
  def payment_failure
    @user = current_user
  end
    
  def payout
    @user = current_user
    # TODO: replace this lookup with balance fields in the User model
    clicks = @user.clicks.find_all_by_state([ Click::State::DEDUCTED, Click::State::FUNDED ])
    @total = clicks.length
    @funded = clicks.count{ |click| Click::State::FUNDED }
    if request.method == 'POST'
      if params.has_key?(:paypal_email)
          # TODO: verify Paypal email before saving
          @user.editing = true
          @user.paypal_email = params[:paypal_email]
          @user.save!
          @user.editing = false
      end
    end
  end
  
end