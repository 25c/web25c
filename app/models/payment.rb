class Payment < ActiveRecord::Base
  
  module State
    NEW = 0
    PROCESSING = 1
    PAID = 2
    # TODO: add payment states if more steps
  end

  belongs_to :user
  
  validates :payment_type,
    :inclusion => {
      :in => %w(payin payout),
      :message => "%{value} is not a valid payment type"
    }
  
  attr_accessible :amount, :state, :payment_type
  
  before_create :generate_uuid
  
  def process
    # TODO: process Paypal payment after admin approval
    
    # Set state to processing
    # self.update_attribute(:state, State::PROCESSING)
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end

end
