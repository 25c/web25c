class AddBalanceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :balance, :integer, :null => false, :default => 0
  end
end
