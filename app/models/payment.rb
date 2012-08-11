class Payment < ActiveRecord::Base
  
  module State
    NEW = 0
    PROCESSING = 1
    PAID = 2
    REFUNDED = 3
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
    if self.payment_type == 'payin'
      if self.state == State::NEW or self.state == State::PROCESSING
        return true if self.update_attribute(:state, State::PAID)
      end
    elsif self.payment_type == 'payout'
    # process payouts after 25c admin approval
    # self.update_attribute(:state, State::PAID)
    end
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end

end
