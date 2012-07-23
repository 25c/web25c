class Click < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"
  
  module State
    NEW = 0
    DEDUCTED = 1
    FUNDED = 2
    PROCESSED = 3
    PAID = 4
    REFUNDED = 5
    DROPPED = 6
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
      return false unless self.state > State::NEW and self.state < State::PROCESSED
      
      # lock and check user balance
      self.user.with_lock do
        # check for credit transfer condition first
        if self.state == State::FUNDED and self.user.balance <= 0
          # search for a deducted click to transfer this funded credit to
          click = Click.where(:user_id => self.user.id, :state => State::DEDUCTED).order('created_at ASC').lock(true).first
          unless click.nil?
            # no user balance change necessary, just change the states of these clicks
            self.update_attribute(:state, State::REFUNDED)
            click.update_attribute(:state, State::FUNDED)
            # return the new funded click
            return click
          end
        end
        
        # in this case, we can just change click state and increment balance
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
      end
    end
    true
  end
  
  def process
    self.with_lock do
      # ensure this click is in a processable state first
      return false unless self.state == State::FUNDED
      
      # update state and increment button provider balance
      self.update_attribute(:state, State::PROCESSED)
      self.connection.execute("PREPARE TRANSACTION 'process-click-#{self.uuid}'")
      begin
        self.button.user.with_lock do
          self.button.user.update_attribute(:balance, self.button.user.balance + 1)
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
    end  
    true  
  end
  
  def self.enqueue(user, button, referrer, request)
    if user.balance > -40
      button = Button.find_by_uuid(button) unless button.kind_of?(Button)
      if not button.nil?
        data = {
          :uuid => UUID.new.generate,
          :user_uuid => user.uuid,
          :button_uuid => button.uuid,
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
    false
  end
  
end
