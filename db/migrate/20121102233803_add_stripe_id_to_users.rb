class AddStripeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_id, :string
    add_column :users, :stripe_last4, :string
    add_column :users, :has_valid_card, :boolean, :default => false
    remove_column :users, :card_token
    remove_column :users, :auto_refill
  end
end