class Home::HomeController < ApplicationController

  before_filter :require_signed_in
  before_filter :check_user_email
  
end