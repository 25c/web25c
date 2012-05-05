class User < ActiveRecord::Base
  has_secure_password
  
  attr_accessible :email, :password
  
  validates_presence_of :email, :password, :if => 'self.facebook_uid.blank?'
  validates_uniqueness_of :email, :if => 'self.facebook_uid.blank?'
  
  before_create :generate_uuid
  
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
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
end
