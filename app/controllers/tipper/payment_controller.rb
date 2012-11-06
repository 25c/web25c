class Tipper::PaymentController < Tipper::TipperController
  
  skip_before_filter :verify_registration, :only => [:site_register, :tip_register]

  def index
    @user = current_user
    if request.method == 'POST'
      save_stripe_info(@user)
      render 'confirm_payment'
    end
  end
  
  def tip_register
    @user = current_user
    if request.method == 'POST'
      save_stripe_info(@user)
      render 'confirm_tip_register', :layout => 'popup'
    else
      render :layout => 'popup'
    end
  end
  
  def site_register
    @user = current_user
    if request.method == 'POST'
      save_stripe_info(@user)
      render 'confirm_site_register'
    end
  end
  
  def create_payment
    @user = current_user
    payment = @user.payments.create!({ :amount => @user.balance, :payment_type => 'payin' })
    respond_to do |format|
      format.json { render :json => { uuid: payment.uuid } }
      format.html { render :nothing => true, :status => 200, :content_type => 'text/html'}
    end
  end
  
  def payment_success

  end
  
  def payment_failure
    @user = current_user
  end
  
  private
  
  def save_stripe_info(user)
    Stripe.api_key = STRIPE_SETTINGS[:secret_key]

    # get the credit card details submitted by the form
    token = params[:stripeToken]
          
    user.editing = true
    
    if user.stripe_id.blank?
      # create a Customer
      customer = Stripe::Customer.create(:card => token, :description => @user.email)
      # save the customer ID
      user.stripe_id = customer.id
    else
      customer = Stripe::Customer.retrieve(user.stripe_id)
      customer.card = token
      customer.save
    end
        
    user.stripe_last4 = customer.active_card.last4
    user.has_valid_card = true
    user.save!
    user.editing = false
  end
  
end