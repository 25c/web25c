class User < ActiveRecord::Base
  has_secure_password
  
  has_many :buttons, :dependent => :destroy  
  has_many :clicks, :dependent => :destroy
  
  has_attached_file :picture
  
  attr_writer :editing
  attr_accessible :email, :password, :nickname, :about, :first_name, :last_name, :picture
  attr_accessible :email, :password, :nickname, :about, :first_name, :last_name, :picture, :is_admin, :as => :admin
  
  validates :email, :presence => true, :if => 'self.facebook_uid.blank?'
  validates :email, :uniqueness => { :case_sensitive => false }, :allow_nil => true
  
  validates :nickname, :uniqueness => { :case_sensitive => false }, :allow_nil => true

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
      return false
    end
  end
  
  def display_name
    name = "#{self.first_name} #{self.last_name}".strip
    name = self.nickname if name.blank?
    name = self.email if name.blank?
    name
  end
  
  def update_profile_from_facebook(include_picture = false)
    file = nil
    begin
      graph = Koala::Facebook::API.new(self.facebook_access_token)
      result = graph.get_object("me", :fields => "first_name,last_name,username,picture", :type => "large")
      self.first_name = result["first_name"]
      self.last_name = result["last_name"]
      self.nickname = result["username"]
      if include_picture
        begin
          file = Curl::Easy.download_file(result["picture"])
          self.picture = file
        rescue
        end
      end
      if self.save
        return true
      else
        self.reload
        return false
      end
    rescue
      # on error, dispatch a job to retry
    ensure
      FileUtils.remove_entry_secure(file.path) unless file.nil?
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
    self.buttons.create(:size => "large")
  end
  
end
