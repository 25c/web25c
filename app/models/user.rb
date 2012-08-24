class User < ActiveRecord::Base
  
  require 'valid_email'
  
  has_secure_password
  
  has_many :buttons, :dependent => :destroy
  has_many :clicks, :dependent => :destroy
  has_many :payments
  
  has_attached_file :picture, :styles => { :thumb => ["50x50#", :jpg], :profile => ["1000x500>", :jpg] }
  
  attr_writer :editing
  attr_accessible :email, :password, :password_confirmation, :nickname, :about, :first_name, 
    :last_name, :picture, :show_donations, :has_agreed, :is_new, :auto_refill, :dwolla_email,
    :dwolla_email_confirmation, :pledge_name, :has_seen_receive_page
  attr_accessible :email, :password, :password_confirmation, :nickname, :about, :first_name, 
    :last_name, :picture, :show_donations, :has_agreed, :is_new, :auto_refill, :dwolla_email,
    :dwolla_email_confirmation, :pledge_name, :has_seen_receive_page, :is_admin, :as => :admin
  
  validates :email, :presence => true, :if => 'not linked?'
  validates :email, :uniqueness => { :case_sensitive => false }, :allow_nil => true, :email => true

  validates :dwolla_email, :uniqueness => { :case_sensitive => false },
    :allow_nil => true, :email => true, :confirmation => true
  validates_confirmation_of :dwolla_email
  
  validates :nickname, :uniqueness => { :case_sensitive => false }, :allow_nil => true

  validates_presence_of :password, :confirmation => true, :if => 'not linked? and not editing?'
  validates_confirmation_of :password
  
  before_validation :preprocess_fields
  before_create :generate_uuid
  
  after_create :create_default_button
  after_save :send_welcome_email
  
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
  
  def update_picture
    file = nil
    begin
      unless self.facebook_uid.blank?
        graph = Koala::Facebook::API.new(self.facebook_access_token)
        self.picture_url = graph.get_picture("me", :type => "large")
      end
      if self.picture_url.blank?
        return
      else
        file = Curl::Easy.download_file(self.picture_url)
        self.picture = file
        self.save!
      end
    rescue
      puts $!.inspect
      # on error, dispatch a job to retry
      Resque.enqueue(BackgroundJob, 'User', self.id, 'update_picture')      
    ensure
      FileUtils.remove_entry_secure(file.path) unless file.nil?
    end
  end
  
  def update_profile
    # dispatch a separate background job to download the profile picture
    Resque.enqueue(BackgroundJob, 'User', self.id, 'update_picture')
    begin
      unless self.facebook_uid.blank?
        graph = Koala::Facebook::API.new(self.facebook_access_token)
        result = graph.get_object("me", :fields => "first_name,last_name,username,email")
        self.first_name = result["first_name"]
        self.last_name = result["last_name"]
        self.nickname = result["username"]
        self.save!
        begin
          self.email = result["email"]
          self.save!
        rescue
          self.reload
        end
      end
    rescue
      # on error, dispatch a job to retry
      Resque.enqueue(BackgroundJob, 'User', self.id, 'update_profile')      
    end
  end
  
  def get_thumb
    if self.picture_updated_at
      picture = self.picture(:thumb) ? self.picture(:thumb) : self.picture
    else
      picture = 'http://i50.tinypic.com/5y6ljo.png'
    end
  end
  
  def profile_url
    if Rails.env.production?
      url = 'https://www.25c.com/'
    else
      url = 'http://localhost:3000/'
    end
    if self.nickname.blank?
      url = ''
    else
      url += self.nickname
    end
  end
  
  private
  
  def preprocess_fields
    self.email = self.email.strip unless self.email.nil?
    self.email = nil if self.email.blank?    
    self.password = self.password.strip unless self.password.nil? 
  end
  
  def linked?
    !(self.facebook_uid.blank? and self.twitter_uid.blank? and self.google_uid.blank?)
  end
  
  def editing?
    @editing
  end
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
  def create_default_button
    self.buttons.create!
  end
  
  def send_welcome_email
    if self.is_new and not self.email.blank?
      UserMailer.welcome(self).deliver
      self.editing = true
      self.is_new = false
      self.save!
      self.editing = false
    end
  end

end
