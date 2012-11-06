class InvitesController < ApplicationController
  
  before_filter :load_invite, :except => :index
  before_filter :require_signed_in, :only => :update
  
  
  def index
    redirect_to root_path
  end
  
  def show
    session[:redirect_path] = request.path unless self.signed_in?
  end
  
  def update
    @invite.process(self.current_user)
    redirect_to publisher_dashboard_path, :notice => t('.invites.update.success')
  end
  
  private
  
  def load_invite
    @invite = Invite.find_by_uuid(params[:id])
    render "home/not_found", :status => 404 if @invite.nil?
  end
  
end
