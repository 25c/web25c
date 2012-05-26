class Click < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
  belongs_to :publisher, :class_name => 'User', :foreign_key => 'publisher_user_id'
  belongs_to :user
  
  attr_accessible :publisher_user_id, :url
  
end
