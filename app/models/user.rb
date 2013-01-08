class User < ActiveRecord::Base
  ROLES = %w(tipper publisher)
  
  require 'valid_email'
  
  has_secure_password
  
  has_many :buttons, :dependent => :destroy
  has_many :clicks, :conditions => { :parent_click_id => nil }
  has_many :payments
  
  has_attached_file :picture, :styles => { 
      :thumb => ["50x50#", :jpg], 
      :profile => ["1000x500>", :jpg] 
    }, 
    :default_url => "https://s3.amazonaws.com/assets.25c.com/users/pictures/missing/:style.jpg"
  
  attr_writer :editing
  attr_accessible :email, :password, :password_confirmation, :nickname, :about, :first_name, 
    :last_name, :picture, :show_donations, :has_agreed, :is_new, :auto_refill, :dwolla_email,
    :dwolla_email_confirmation, :pledge_name, :has_seen_receive_page
  attr_accessible :email, :password, :password_confirmation, :nickname, :about, :first_name, 
    :last_name, :picture, :show_donations, :has_agreed, :is_new, :auto_refill, :dwolla_email,
    :dwolla_email_confirmation, :pledge_name, :has_seen_receive_page, :is_admin, :as => :admin
  
  validates :email, :presence => true, :if => 'not linked?'
  validates :email, :uniqueness => { :case_sensitive => false, :scope => 'role' }, :allow_nil => true, :email => true

  validates :dwolla_email, :uniqueness => { :case_sensitive => false },
    :allow_nil => true, :email => true, :confirmation => true
  validates_confirmation_of :dwolla_email
  
  validates :nickname, :uniqueness => { :case_sensitive => false }, :allow_nil => true

  validates_presence_of :password, :confirmation => true, :if => 'not linked? and not editing?'
  validates_confirmation_of :password
  
  validates :role, :inclusion => { :in => ROLES }
  
  before_validation :preprocess_fields
  before_create :generate_uuid
  
  after_save :send_welcome_email
  
  def self.from_omniauth(auth)
    user = nil
    is_new = false
    case auth['provider']
    when 'google_oauth2'
      user = User.find_by_google_uid(auth['uid'])
      user = User.find_by_email_ci(auth['info']['email']) if user.nil? and not auth['info']['email'].blank?
      if user.nil?
        user = User.new(:password => SecureRandom.hex) if user.nil?
        is_new = true
      end
      user.google_uid = auth['uid']
      user.google_token = auth['credentials']['token']
      user.google_refresh_token = auth['credentials']['refresh_token']
      user.email = auth['info']['email']
      user.first_name = auth['info']['first_name'] if user.first_name.blank?
      user.last_name = auth['info']['last_name'] if user.last_name.blank?
      user.picture_url = auth['info']['image'] unless user.picture?
      user.save!
    when 'identity'
      user = User.find_by_id(auth['uid'])
      raise Exception.new("User not found in omniauth identity callback") if user.nil?
    when 'facebook'
      user = User.find_by_facebook_uid(auth['uid'])
      user = User.find_by_email_ci(auth['info']['email']) if user.nil? and not auth['info']['email'].blank?
      if user.nil?
        user = User.new(:password => SecureRandom.hex) if user.nil?
        is_new = true
      end
      user.facebook_uid = auth['uid']
      user.facebook_access_token = auth['credentials']['token']
      user.email = auth['info']['email'] if user.email.blank?
      user.first_name = auth['info']['first_name'] if user.first_name.blank?
      user.last_name = auth['info']['last_name'] if user.last_name.blank?
      user.picture_url = auth['info']['image'] unless user.picture?
      user.save!
    else
      raise Exception.new("Unsuppored omniauth strategy: #{auth['provider']}")
    end
    return { :user => user, :is_new => is_new }
  end
  
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
  
  def to_param
    self.nickname
  end
  
  def publisher?
    self.role == 'publisher'
  end
  
  def tipper?
    self.role == 'tipper'
  end
  
  def balance
    self.balance_paid + self.balance_free
  end
  
  def balance_value
    self.balance * 0.25
  end
  
  def clicks_received
    Click.where(:receiver_user_id => self.id)
  end
  
  def display_name
    name = self.pledge_name
    name = "#{self.first_name} #{self.last_name}".strip if name.blank?
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
      Airbrake.notify($!)
      # puts $!.inspect
      # on error, dispatch a job to retry
      # Resque.enqueue(BackgroundJob, 'User', self.id, 'update_picture')      
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
      Airbrake.notify($!)
      # on error, dispatch a job to retry
      # Resque.enqueue(BackgroundJob, 'User', self.id, 'update_profile')      
    end
  end
  
  def get_thumb
    if self.picture_updated_at
      picture = self.picture(:thumb) ? self.picture(:thumb) : self.picture
    else
      picture = 'https://s3.amazonaws.com/assets.25c.com/users/pictures/no_pic.png'
    end
  end
  
  def profile_url
    if Rails.env.production?
      url = 'https://tip.25c.com/'
    elsif Rails.env.staging?
      url = 'https://tip.plus25c.com/'
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
  
  def send_welcome_email
    if self.is_new and not self.email.blank?
      if self.role == "tipper" 
        UserMailer.new_user_welcome(self.id).deliver
      else 
        UserMailer.new_publisher_welcome(self.id).deliver
      end
      self.editing = true
      self.is_new = false
      self.save!
      self.editing = false
    end
  end

end
