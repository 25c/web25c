class Tipper::TipperController < ApplicationController

  before_filter :require_tipper, :verify_registration
  
  def verify_registration
    unless self.signed_in? and self.current_user.has_valid_card
      redirect_to tipper_site_register_path
    end
  end

end