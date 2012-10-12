class Home::AccountController < Home::HomeController
  
  # include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token, :only => :payment_success

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
    @has_payin = @user.balance > 1000000000
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
    
  def payout
    @user = current_user
    
    # TODO: replace this lookup with balance fields in the User model
    clicks = Click.where(:receiver_user_id => @user.id).find_all_by_state([ 
      Click::State::DEDUCTED, Click::State::FUNDED, Click::State::QUEUED
    ])
    funded_clicks = clicks.select{ |click| click.state > Click::State::DEDUCTED }
    @total = 0
    clicks.each do |click|
      @total += click.amount
    end
    @funded = 0
    funded_clicks.each do |click|
      @funded += click.amount
    end
    
    if @funded < 25
      @has_payout = false
    else
      @has_payout = true
      
      if request.method == 'POST'
        # if Dwolla code
        # code = params['code']
        # dwolla_token = DwollaClient.request_token(code, redirect_uri)
        @user.editing = true
        unless @user.update_attributes(params[:user])
          respond_to do |format|
            format.html { flash.now[:alert] = t('home.account.payout.dwolla_warning') }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
          @user.reload
          return
        end
      end
      
      # @authUrl = DwollaClient.auth_url(dwolla_auth_callback_url)
      unless @user.dwolla_email.blank?
        # Create or update payment object
        amount = @funded
        openPayments = @user.payments.where(:state => Payment::State::NEW, :payment_type => 'payout')
        if openPayments.empty?
          payment = @user.payments.new({:amount => amount, :payment_type => 'payout'})
          ApplicationMailer.new_payout_request(@user, payment).deliver
        elsif openPayments.length == 1
          payment = openPayments[0]
          payment.amount = amount.to_i unless openPayments[0].amount == amount.to_i
          ApplicationMailer.updated_payout_request(@user, payment).deliver
        else
          # error: multiple open payouts
          raise "User #{@user.id} has multiple open payout request"
        end
        payment.save
        # TODO make this click processing a background task
        funded_clicks.each{|click| click.queue_for_payout }
      end
    end
  end
  
end