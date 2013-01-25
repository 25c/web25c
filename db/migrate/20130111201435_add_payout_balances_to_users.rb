class AddPayoutBalancesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payout_available, :bigint, :default => 0
    add_column :users, :payout_estimate, :bigint, :default => 0
  end
end
