class User < ActiveRecord::Base
  has_secure_password
  
  attr_accessible :email, :password
  
  validates_presence_of :email, :password
  validates_uniqueness_of :email
  
  before_create :generate_uuid
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
end
