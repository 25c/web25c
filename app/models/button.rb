class Button < ActiveRecord::Base
  belongs_to :user
  
  has_many :clicks
  
  validates :size, 
    :inclusion => { 
      :in => %w(btn_large btn_medium btn_small icon_large icon_medium icon_small),
      :message => "%{value} is not a valid button size" 
    }
  
  validates :code_type,
    :inclusion => { 
      :in => %w(javascript iframe),
      :message => "%{value} is not a valid button size" 
    }
  before_create :generate_uuid, :assign_defaults
  
  attr_accessible :size, :title, :description, :code_type
  
  def to_param
    self.uuid
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
  def assign_defaults
    self.code_type = "javascript"
    self.size = "btn_large"
  end
  
end