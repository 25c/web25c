class Content < ActiveRecord::Base
  belongs_to :user
  
  validates :name, :presence => true
  
  before_create :generate_uuid
  
  attr_accessible :name
  
  def to_param
    self.uuid
  end
  
  private 
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
end