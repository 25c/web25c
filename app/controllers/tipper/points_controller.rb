class Tipper::PointsController < Tipper::TipperController
  
  def index
    @payments = self.current_user.payments.order('created_at DESC').page params[:page]
    render :partial => 'payments' if request.xhr?
  end
  
  def remove_card
    begin
      customer = Stripe::Customer.retrieve(self.current_user.stripe_id)
      customer.delete
      self.current_user.editing = true
      self.current_user.stripe_id = nil
      self.current_user.stripe_type = nil
      self.current_user.stripe_exp_month = nil
      self.current_user.stripe_exp_year = nil
      self.current_user.has_valid_card = nil
      self.current_user.save!
      redirect_to tipper_points_path, :notice => t('tipper.points.remove_card.success')
    rescue => e
      redirect_to tipper_points_path, :alert => e.to_s
    end
  end
  
  def checkout
    @amount_points = params[:amount].to_i
    redirect_to tipper_points_path, :alert => t('tipper.points.checkout.invalid_amount') unless [ 20, 45, 100, 300, 700 ].include?(@amount_points)    
    @amount_values = {
      20 => 500,
      45 => 1000,
      100 => 2000,
      300 => 5000,
      700 => 10000
    }    
    if request.method == 'POST'
      begin
        token = params[:stripe_token]
        unless params[:save].nil? or token.nil?
          # save card info into customer object
          if self.current_user.stripe_id.blank?
            # create a Customer
            customer = Stripe::Customer.create(:card => token, :description => "#{self.current_user.uuid} (#{self.current_user.email})")
            self.current_user.stripe_id = customer.id
          else
            customer = Stripe::Customer.retrieve(self.current_user.stripe_id)
            customer.card = token
            customer.description = "#{self.current_user.uuid} (#{self.current_user.email})"
            customer.save
          end
          # save display info
          self.current_user.editing = true
          self.current_user.stripe_last4 = customer.active_card.last4
          self.current_user.stripe_type = customer.active_card.type
          self.current_user.stripe_exp_month = customer.active_card.exp_month
          self.current_user.stripe_exp_year = customer.active_card.exp_year
          self.current_user.has_valid_card = true
          self.current_user.save!
        end
        # charge card
        charge = {
          :amount => @amount_values[@amount_points],
          :currency => 'usd',
          :description => "#{@amount_points} points for #{self.current_user.uuid} (#{self.current_user.email})"
        }
        if self.current_user.stripe_id.blank?
          charge[:card] = token
        else
          charge[:customer] = self.current_user.stripe_id
        end
        self.current_user.with_lock do
          charge = Stripe::Charge.create(charge)
          self.current_user.balance_paid += @amount_points
          self.current_user.save!
          payment = self.current_user.payments.build
          payment.transaction_id = charge.id
          payment.amount_points = @amount_points
          payment.amount_value = @amount_values[@amount_points]
          payment.currency = 'usd'
          payment.save!
        end
        redirect_to tipper_points_path, :notice => t('tipper.points.checkout.success')
        return
      rescue Stripe::CardError => e
        # Since it's a decline, Stripe::CardError will be caught
        body = e.json_body
        err  = body['error']

        puts "Status is: #{e.http_status}"
        puts "Type is: #{err['type']}"
        puts "Code is: #{err['code']}"
        # param is '' in this case
        puts "Param is: #{err['param']}"
        puts "Message is: #{err['message']}"
      rescue Stripe::InvalidRequestError => e
        # Invalid parameters were supplied to Stripe's API
      rescue Stripe::AuthenticationError => e
        # Authentication with Stripe's API failed
        # (maybe you changed API keys recently)
      rescue Stripe::APIConnectionError => e
        # Network communication with Stripe failed
      rescue Stripe::StripeError => e
        # Display a very generic error to the user, and maybe send
        # yourself an email
      rescue => e
        # Something else happened, completely unrelated to Stripe
      end      
      redirect_to tipper_points_path, :alert => e.to_s
    end
  end
  
end
