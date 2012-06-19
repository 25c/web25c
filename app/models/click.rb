class Click < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
  belongs_to :button
  belongs_to :user
  
end
