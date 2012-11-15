class Url < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
end
