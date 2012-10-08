class Invite < ActiveRecord::Base
  attr_accessible :email, :state, :uuid, :share_amount
  after_create :new_invite_email
  
  module State
    OPEN = 0
    ACCEPTED = 1
    CLOSED = 2
  end
  
  belongs_to :button
  before_create :generate_uuid
  
  def generate_uuid
    self.uuid = UUID.new.generate
  end
  
  def new_invite_email
    unless self.email.blank?
      UserMailer.new_invite(self).deliver
    end
  end
  
  def update_amount(amount)
    self.share_amount = amount
    # TODO: send update email to user indicating update
    self.save
  end
  
  def process(user)
    unless self.button.user == user
      self.button.share_users = [{ :user => user.id, :share_amount => self.share_amount }]
      self.button.save
      self.state = State::ACCEPTED
      self.save
    end
  end
  
end
