class Click < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
  module State
    NEW = 0
    DEDUCTED = 1
    FUNDED = 2
    PAID = 3
    REFUNDED = 4
    DROPPED = 5
  end
  
  belongs_to :button
  belongs_to :user
  
  before_create :generate_uuid
  
  attr_accessible :user_id, :ip_address, :button_id
  
  def generate_uuid
    self.uuid = UUID.new.generate
  end
  
  def undo
    self.with_lock do
      # ensure this click is in an undo-able state
      return false unless self.state == State::DEDUCTED
        
      # change click state and increment balance
      self.update_attribute(:state, State::REFUNDED)
      self.connection.execute("PREPARE TRANSACTION 'undo-click-#{self.uuid}'")
      begin
        self.user.update_attribute(:balance, self.user.balance + 1)
        self.user.connection.execute("PREPARE TRANSACTION 'undo-user-#{self.uuid}'")
        begin
          self.user.connection.execute("COMMIT PREPARED 'undo-user-#{self.uuid}'")
        rescue
          self.user.connection.execute("ROLLBACK PREPARED 'undo-user-#{self.uuid}'")
          raise $!
        end
      rescue
        self.connection.execute("ROLLBACK PREPARED 'undo-click-#{self.uuid}'")
      end
      self.connection.execute("COMMIT PREPARED 'undo-click-#{self.uuid}'")
      
      DATA_REDIS.decr "#{self.user.uuid}:#{self.button.uuid}"
      DATA_REDIS.set "user:#{self.user.uuid}", self.user.balance
    end
    true
  end
  
  def process
    self.with_lock do
      # ensure this click is in a processable state first
      return false unless self.state == State::DEDUCTED
      
      # update state and increment user balance
      self.update_attribute(:state, State::FUNDED)
      self.connection.execute("PREPARE TRANSACTION 'process-click-#{self.uuid}'")
      begin
        self.button.user.with_lock do
          self.user.update_attribute(:balance, self.user.balance + 1)
          self.button.user.connection.execute("PREPARE TRANSACTION 'process-user-#{self.uuid}'")
          begin
            self.button.user.connection.execute("COMMIT PREPARED 'process-user-#{self.uuid}'")
          rescue
            self.button.user.connection.execute("ROLLBACK PREPARED 'process-user-#{self.uuid}'")
            raise $!
          end
        end
      rescue
        self.connection.execute("ROLLBACK PREPARED 'process-click-#{self.uuid}'")
      end
      self.connection.execute("COMMIT PREPARED 'process-click-#{self.uuid}'")
      
      # update user balance and user click per button caches
      DATA_REDIS.decr "#{self.user.uuid}:#{self.button.uuid}"
      DATA_REDIS.set "user:#{self.user.uuid}", self.user.balance
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
    else
      # TODO: notify user of overdraft
    end
    false
  end
  
end
