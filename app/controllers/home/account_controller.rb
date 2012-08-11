class Home::AccountController < Home::HomeController
  
  include ActiveMerchant::Billing::Integrations
  
  def index
    # unreachable
  end
  
  def payment
    @user = current_user
    # TODO: replace this lookup with balance fields in the User model
    clicks = @user.clicks.find_all_by_state([ 
      Click::State::DEDUCTED
    ])
    @total = clicks.length
    @has_payin = @total >= 40
  end
  
  def create_payment
    @user = current_user
    openPayments = @user.payments.where(:state => Payment::State::NEW, :payment_type => 'payin')
    if openPayments.empty?
      payment = @user.payments.create!({ :amount => 10, :payment_type => 'payin' })
    elsif openPayments.length == 1
      payment = openPayments[0]
    else
      # error: multiple open payouts
    end
    respond_to do |format|
      format.json { render :json => { uuid: payment.uuid } }
      format.html { render :nothing => true, :status => 200, :content_type => 'text/html'}
    end
  end
  
  def payment_success
    @user = current_user
  end
  
  def payment_failure
    @user = current_user
  end
    
  def payout
    @user = current_user
    
    if request.method == 'POST'
      auth = request.env['omniauth.auth']
      user = nil
      if auth['provider'] == 'paypal'
        puts auth.inspect
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
        openPayments = @user.payments.where(:state => Payment::State::NEW, :payment_type => 'payout')
        if openPayments.empty?
          @user.payments.create!({:amount => amount, :payment_type => 'payout'})
        elsif openPayments.length == 1
          openPayments[0].update_attribute(:amount, amount) unless openPayments[0].amount == amount
        else
          # error: multiple open payouts
        end
      end
    end
  end
  
end