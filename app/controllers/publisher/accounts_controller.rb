class Publisher::AccountsController < Publisher::PublisherController
  
  def show
    
  end
  
  def update
    self.current_user.editing = true
    if self.current_user.update_attributes(params[:user])
      redirect_to publisher_user_path, :notice => t('publisher.accounts.update.success')
    else
      render :show
    end
  end
  
end
