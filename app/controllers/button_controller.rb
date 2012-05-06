class ButtonController < ApplicationController
  
  def button
    render :partial=>'button'
  end
  
  def state
    respond_to do |format|
      if self.signed_in?
        format.json { render :json => { :response => :ok } }
      else
        format.json { render :json => { :response => :unauthorized } }
      end
    end
  end
  
  def click
    respond_to do |format|
      if self.signed_in?
        publisher_user = User.find_by_uuid(params[:publisher_id])
        self.current_user.clicks_submitted.create!(:publisher_user_id => publisher_user.id, :url => params[:url])
        format.json { render :json => { :response => :ok } }
      else
        format.json { render :json => { :response => :unauthorized } }
      end
    end
  end
  
end
