class Button < ActiveRecord::Base
  belongs_to :user
  
  has_many :clicks
  
  has_attached_file :picture
  
  validates :size,
    :inclusion => {
      :in => %w(btn-large btn-medium btn-small icon-large icon-medium icon-small icon-text),
      :message => "%{value} is not a valid button size" 
    }
  
  validates :code_type,
    :inclusion => { 
      :in => %w(javascript iframe),
      :message => "%{value} is not a valid button size" 
    }
    
  before_create :generate_uuid
  
  before_validation :assign_defaults
  
  attr_accessible :size, :title, :description, :code_type, :picture, :youtube_id
  
  def to_param
    self.uuid
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
  def assign_defaults
    self.code_type = "javascript" if self.code_type.blank?
    self.size = "btn-large" if self.size.blank?
  end
  
end