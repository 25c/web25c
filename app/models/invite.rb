class Invite < ActiveRecord::Base
  attr_accessible :email, :state, :uuid
  
  module State
    OPEN = 0
    ACCEPTED = 1
    CLOSED = 2
  end
  
  belongs_to :button
  before_create :generate_uuid
  
  def generate_uuid
    self.uuid = UUID.new.generate
  end
  
end
