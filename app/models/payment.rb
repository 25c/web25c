class Payment < ActiveRecord::Base
  
  module State
    NEW = 0
    # TODO: add payment states based on transaction steps
  end

  belongs_to :user
  
  validates :payment_type,
    :inclusion => {
      :in => %w(payin payout),
      :message => "%{value} is not a valid payment type"
    }
  
  attr_accessible :user_paypal_email, :amount, :state, :payment_type
  
  before_create :generate_uuid

  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end

end
