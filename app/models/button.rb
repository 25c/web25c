class Button < ActiveRecord::Base
  belongs_to :user
  
  validates :size, :inclusion => { :in => %w(icon medium large),
      :message => "%{value} is not a valid button size" }
  
  before_create :generate_uuid, :default_size
  
  attr_accessible :size, :title, :description
  
  def to_param
    self.uuid
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
  def default_size
    self.size = "large"
  end
  
end