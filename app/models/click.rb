class Click < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
  belongs_to :button
  belongs_to :user
  
  before_create :generate_uuid
  
  attr_accessible :user_id, :ip_address, :button_id
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
end
