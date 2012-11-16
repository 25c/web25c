class Payment < ActiveRecord::Base
  
  module State
    NEW = 0
    PROCESSING = 1
    PAID = 2
    REFUNDED = 3
  end
  
  belongs_to :user
  has_many :clicks, :conditions => { :parent_click_id => nil }
  
  validates :payment_type,
    :inclusion => {
      :in => %w(payin payout),
      :message => "%{value} is not a valid payment type"
    }
  
  attr_accessible :amount, :state, :payment_type
  
  before_create :generate_uuid
  
  def process
    # process payouts after 25c admin approval
    if self.payment_type == 'payin'
      response = HTTParty.post(ENV['DATA25C_URL'] + '/api/payments/process', :body => { :uuids => [ self.uuid ] })
      response.code == 200
    elsif self.payment_type == 'payout'
      # TODO - replace with automatic processing with Dwolla
      self.update_attribute(:state, State::PAID)
      clicks = Click.where(:button_id => self.user.button_ids).find_all_by_state(Click::State::QUEUED)
      clicks.each{ |click| click.set_paid }
    end
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end

end
