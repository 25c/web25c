class Home::AccountController < Home::HomeController
  
  def index
    render :jar
  end
  
  def jar
    @user = current_user
  end
  
  def confirm
    @user = current_user
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      render :action => "confirm"
    else
      @amount = calculate_amount
      render :action => "jar"
    end
  end
  
  protected

  def calculate_amount
    # placeholder for code that calculates amount to be charged
    "100.00"
  end
  
end