class AddShareAmountToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :share_amount, :integer, :default => 0
  end
end
