class Click < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
  module State
    NEW = 0
    DEDUCTED = 1
    FUNDED = 2
    QUEUED = 3
    PAID = 4
    REFUNDED = 5
    DROPPED = 6
  end
  
  belongs_to :button
  belongs_to :user
  belongs_to :comment
  belongs_to :url
  belongs_to :payment
  
  has_many :clicks, :foreign_key => 'parent_click_id'
  
  before_create :generate_uuid
  
  attr_accessible :user_id, :ip_address, :button_id
  
  def referrer_title
    @title ||= Click.connection.select_value("SELECT title FROM urls WHERE url='#{self.referrer}'")
    @title ||= self.referrer
  end
  
  def generate_uuid
    self.uuid = UUID.new.generate
  end
  
  def undo
    response = HTTParty.post(ENV['DATA25C_URL'] + '/api/clicks/undo', :body => { :uuids => [ self.uuid ] })
    response.code == 200
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
