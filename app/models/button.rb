class Button < ActiveRecord::Base
  belongs_to :user
  
  has_many :clicks
  has_many :invites
    
  attr_accessible :title, :description, :pledge_message, :widget_type, :additional_parameters
  
  serialize :share_users, JSON
  
  serialize :additional_parameters, JSON
    
  before_create :generate_uuid
    
  def to_param
    self.uuid
  end
  
  def share_invite(email, amount)
    if not email.blank? and amount.to_i > 0
      self.invites.create(:email => email, :share_amount => amount.to_i)
    end
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
end