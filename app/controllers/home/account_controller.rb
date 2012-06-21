class Home::AccountController < Home::HomeController
  
  def index
    render :jar
  end
  
  def jar
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
        :amount => params[:transaction][:amount],
        :customer_id => @user.uuid,
        :payment_method_token => @user.card_token
      )

    # transparent redirect payment for new card
    else
      begin
        @result = Braintree::TransparentRedirect.confirm(request.query_string)
      rescue
        # something went wrong - not a new or existing card
        flash[:notice] = t('home.account.jar.payment_failure')
        redirect_to home_jar_path
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

      @user.balance += @result.transaction.amount
      
      respond_to do |format|
        if @user.save
          format.html {
            flash.now[:notice] = t('home.account.confirm.success')
            render :action => "confirm_payment"
          }
        else
          format.html {
            flash.now[:notice] = t('home.account.confirm.failure')
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
      render :action => "jar"
    end
  end
  
  def payout
    @user = current_user
  end
  
  def confirm_payout
  end
  
  def set_refill
    @user = current_user
    @user.editing = true
    @user.auto_refill = (params[:auto_refill] == 'true');
    @user.save
    @user.editing = false
    render :nothing => true
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