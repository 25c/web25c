class Home::HomeController < ApplicationController
  before_filter :require_signed_in
  
end
