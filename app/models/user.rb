class User < ActiveRecord::Base
  has_secure_password
  
  has_many :buttons, :dependent => :destroy
  
  has_many :clicks_submitted, :class_name => 'Click', :dependent => :destroy
  has_many :clicks_received, :class_name => 'Click', :foreign_key => :publisher_user_id, :dependent => :destroy
  
  attr_writer :editing
  attr_accessible :email, :password
  attr_accessible :email, :password, :is_admin, :as => :admin
  
  validates_presence_of :email, :if => 'self.facebook_uid.blank?'
  validates_uniqueness_of :email, :if => 'self.facebook_uid.blank?'

  validates_presence_of :password, :if => 'self.facebook_uid.blank? and not editing?'
  
  before_validation :preprocess_fields
  before_create :generate_uuid
  after_create :create_default_button
  
  def refresh_facebook_access_token(code, force_refresh = false)
    begin
      if force_refresh or self.facebook_code != code
        oauth = Koala::Facebook::OAuth.new(FACEBOOK_SETTINGS['app_id'], FACEBOOK_SETTINGS['app_secret'])
        access_token = oauth.get_access_token(code)
        extended_access_token_info = oauth.exchange_access_token_info(access_token)
        self.facebook_code = code
        self.facebook_access_token = extended_access_token_info['access_token']
        if self.save
          return true
        else
          self.reload
          return false
        end
      end
      return true
    rescue
      puts $!.inspect
      return false
    end
  end
  
  private
  
  def preprocess_fields
    self.email = self.email.strip unless self.email.nil?
    self.email = nil if self.email.blank?    
    self.password = self.password.strip unless self.password.nil?
  end
  
  def editing?
    @editing
  end
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
  def create_default_button
    self.current_user.buttons.build(:size => "large")
  end
  
end
