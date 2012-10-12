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
  
  has_many :clicks, :foreign_key => 'parent_click_id'
  
  before_create :generate_uuid
  
  attr_accessible :user_id, :ip_address, :button_id
  
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
  
  def self.enqueue(user, button, referrer, request, cookies)
    if user.balance > -40
      button = Button.find_by_uuid(button) unless button.kind_of?(Button)
      if not button.nil?
        referrer_user_uuid = nil
        if cookies['_25c_referrer']
          referrer_data_str = REDIS.get(cookies['_25c_referrer'])
          if referrer_data_str
            referrer_data = JSON.parse(referrer_data_str)
            if referrer.start_with?(referrer_data['url'])
              referrer_user_uuid = referrer_data['referrer_user_uuid']
            end
          end
        end
        data = {
          :uuid => UUID.new.generate,
          :user_uuid => user.uuid,
          :button_uuid => button.uuid,
          :referrer_user_uuid => referrer_user_uuid,
          :referrer => referrer,
          :user_agent => request.env['HTTP_USER_AGENT'],
          :ip_address => request.remote_ip,
          :created_at => Time.new.utc
        }
        counter_key = "#{user.uuid}:#{button.uuid}"
        DATA_REDIS.multi do
          DATA_REDIS.lpush 'QUEUE', data.to_json
          DATA_REDIS.incr counter_key
        end
        return true
      end
    end
    return false
  end
  
end
