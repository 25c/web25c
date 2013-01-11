class AddPayoutBalancesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payout_available, :bigint
    add_column :users, :payout_estimate, :bigint
  end
end
