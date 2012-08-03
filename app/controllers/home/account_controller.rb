class Home::AccountController < Home::HomeController
  
  def index
    render :payment
  end
  
  def payment
    @user = current_user
    braintree_info = get_braintree_info(@user)
    @card_masked_number = braintree_info[:card_masked_number]
    is_on_braintree = braintree_info[:is_on_braintree]
    @bt_data = get_bt_data(@user, is_on_braintree)
  end
  
  def confirm_payment
    @user = current_user
    
    # server-to-server payment from vault for existing card
    if params[:payment_type] == "existing"
      @result = Braintree::Transaction.sale(
        :amount => (params[:transaction][:amount]),
        :customer_id => @user.uuid,
        :payment_method_token => @user.card_token
      )

    # transparent redirect payment for new card
    else
      begin
        @result = Braintree::TransparentRedirect.confirm(request.query_string)
      rescue
        # something went wrong - not a new or existing card
        flash[:notice] = t('home.account.payment.payment_failure')
        redirect_to home_payment_path
        return nil
      end
    end
    
    if @result.success?
      @user.editing = true
      new_card_token = @result.transaction.credit_card_details.token
      
      if !new_card_token.blank?
        # if user doesn't have a card token yet, add it
        if @user.card_token.blank?
          @user.card_token = new_card_token
    
        # if token is different, delete other token stored on BT
        elsif @user.card_token != new_card_token
          for card in Braintree::Customer.find(@user.uuid).credit_cards
            if card.token != new_card_token
              Braintree::CreditCard.delete(card.token)
            end
          end
          @user.card_token = new_card_token
        end
      end

      # hard-coded 25c value - assumes dollars
      @user.balance += @result.transaction.amount * 4
      
      respond_to do |format|
        if @user.save
          format.html {
            flash.now[:notice] = t('home.account.confirm_payment.success')
            render :action => "confirm_payment"
          }
        else
          format.html {
            flash.now[:alert] = t('home.account.confirm_payment.failure')
            render :action => "confirm_payment"
          }
        end
      end
  
      @user.editing = false
      
    else
      braintree_info = get_braintree_info(@user)
      @card_masked_number = braintree_info[:card_masked_number]
      is_on_braintree = braintree_info[:is_on_braintree]
      @bt_data = get_bt_data(@user, is_on_braintree)
      render :action => "payment"
    end
  end
  
  def payout
    @user = current_user
    # TODO: replace this lookup with balance fields in the User model
    clicks = @user.clicks.find_all_by_state([ 1, 2 ])
    @total = clicks.length
    @funded = clicks.count{ |click| click.state == 2 }
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
  
  private
  def get_braintree_info(user)
    card_masked_number = ''
    is_on_braintree = false
    begin
      customer = Braintree::Customer.find(user.uuid)
      is_on_braintree = true
      if customer.credit_cards.length
        card_masked_number = customer.credit_cards[0].masked_number
      end
    rescue
      puts "No Braintree customer found"
    end
    return {
      :card_masked_number => card_masked_number, 
      :is_on_braintree => is_on_braintree
    }
  end
  
  private
  def get_bt_data(user, is_on_braintree)
    if is_on_braintree
      bt_data = Braintree::TransparentRedirect.transaction_data(
        :redirect_url => home_confirm_payment_url,
        :transaction => {
          :type => "sale",
          :customer_id => user.uuid
        }
      )
    else
      bt_data = Braintree::TransparentRedirect.transaction_data(
        :redirect_url => home_confirm_payment_url,
        :transaction => {
          :type => "sale",
          :customer => {
              :id => user.uuid
          }
        }
      )
    end
    return bt_data
  end

end