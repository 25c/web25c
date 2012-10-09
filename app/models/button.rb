class Button < ActiveRecord::Base
  belongs_to :user
  
  has_many :clicks
  has_many :invites
  
  has_attached_file :picture
  
  attr_accessible :size, :title, :description, :code_type, :picture, :youtube_id, :pledge_message
  
  serialize :share_users
  
  validates :size,
    :inclusion => {
      :in => %w(btn-large btn-medium btn-small icon-large icon-medium icon-small tip-large tip-medium tip-small),
      :message => "%{value} is not a valid button size"
    }

  validates :code_type,
    :inclusion => {
      :in => %w(javascript iframe),
      :message => "%{value} is not a valid button code type"
    }
    
  before_create :generate_uuid
  
  before_validation :assign_defaults
  
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