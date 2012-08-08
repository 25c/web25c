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
    if request.method == 'POST'
      if params.has_key?(:paypal_email)
          # TODO: verify Paypal email before saving
          @user.editing = true
          @user.paypal_email = params[:paypal_email]
          @user.save!
          @user.editing = false
      end
    end
    # TODO: replace this lookup with balance fields in the User model
    clicks = Click.where(:button_id => @user.button_ids).find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED
    ])
    @total = clicks.length
    @funded = clicks.count{ |click| click.state == Click::State::FUNDED }
    
    if @funded < 200
      @has_payout = false
    else
      @has_payout = true
      unless @user.paypal_email.blank?
        # Create or update payment object
        amount = (@funded.to_f / 4).round(2)
        openPayments = @user.payments.find_all_by_state(Payment::State::NEW)
        if openPayments.empty?
          @user.payments.create!({:amount => amount, :payment_type => 'payout'})
        elsif openPayments.length == 1
          openPayments[0].update_attribute(:amount, amount) unless openPayments[0].amount == amount
        else
          # error: multiple open payouts - might need to notify admin
        end
      end
    end
    
  end
  
end