class FixUserBalance < ActiveRecord::Migration
  def up
    User.find_each do |user|
      user.update_attribute(:balance, user.clicks.where(:state => Click::State::DEDUCTED).sum(:amount))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
