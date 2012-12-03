class Comment < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
  belongs_to :user
  belongs_to :button
  belongs_to :url
  belongs_to :click
  
end
