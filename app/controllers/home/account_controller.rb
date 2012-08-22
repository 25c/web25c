class Home::AccountController < Home::HomeController
  
  # include ActiveMerchant::Billing::Integrations

  require 'dwolla.rb'
  DwollaClient = Dwolla::Client.new(DWOLLA_SETTINGS[:app_key], DWOLLA_SETTINGS[:app_secret])
  
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
      # if Dwolla code
      # code = params['code']
      # dwolla_token = DwollaClient.request_token(code, redirect_uri)
      @user.editing = true
      unless @user.update_attributes(params[:user])
        # TODO: handle bad Dwolla email
      end
    end
    
    # TODO: replace this lookup with balance fields in the User model
    clicks = Click.where(:button_id => @user.button_ids).find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED, Click::State::QUEUED
    ])
    funded_clicks = clicks.select{ |click| click.state > Click::State::DEDUCTED }
    @total = clicks.length
    @funded = funded_clicks.length
    
    # if @funded < 40
    if false
      @has_payout = false
    else
      @has_payout = true
      # @authUrl = DwollaClient.auth_url(dwolla_auth_callback_url)
      
      # unless @user.paypal_email.blank?
      #   # Create or update payment object
      #   amount = (@funded.to_f / 4).round(2)
      #   openPayments = @user.payments.where(:state => Payment::State::NEW, :payment_type => 'payout')
      #   if openPayments.empty?
      #     payment = @user.payments.new({:amount => amount, :payment_type => 'payout'})
      #     ApplicationMailer.new_payout_request(@user, payment).deliver
      #   elsif openPayments.length == 1
      #     payment = openPayments[0]
      #     payment.amount = amount unless openPayments[0].amount == amount
      #     ApplicationMailer.updated_payout_request(@user, payment).deliver
      #   else
      #     # error: multiple open payouts
      #     raise "User #{@user.id} has multiple open payout request"
      #   end
      #   payment.save
      #   # TODO make this click processing a background task
      #   funded_clicks.each{|click| click.queue_for_payout }
      # end
    end
  end
  
end