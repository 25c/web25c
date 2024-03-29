class Click < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"

  module State
    GIVEN = 'given'
    PAID = 'paid'
  end
  STATES = [ Click::State::GIVEN, Click::State::PAID ]
  
  belongs_to :button
  belongs_to :user
  belongs_to :comment
  belongs_to :url
  belongs_to :payment
  
  has_many :clicks, :foreign_key => 'parent_click_id'
  
  before_create :generate_uuid
  
  attr_accessible :user_id, :ip_address, :button_id
  
  def to_param
    self.uuid
  end
  
  def editable?
    self.created_at > (Time.now.utc - 60.minute)
  end
  
  def amount_value
    self.amount * 0.25
  end
  
  def referrer_title
    @title ||= Click.connection.select_value("SELECT title FROM urls WHERE url='#{self.referrer}'")
    @title ||= self.referrer
  end
  
  def generate_uuid
    self.uuid = UUID.new.generate
  end
  
  def cancel
    begin
      response = HTTParty.post(ENV['DATA25C_URL'] + '/api/clicks/undo', :body => { :uuids => [ self.uuid ] })
      return response.code == 200
    rescue
      return false
    end
  end
  
  def queue_for_payout
    self.with_lock do
      # ensure this click is in the right state
      return false unless self.state == State::FUNDED
      # change click state
      self.update_attribute(:state, State::QUEUED)
    end
    true
  end
  
  def set_paid
    self.with_lock do
      # ensure this click is in the right state
      return false unless self.state == State::QUEUED
      # change click state
      self.update_attribute(:state, State::PAID)
    end
    true
  end
  
end
