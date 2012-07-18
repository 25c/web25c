class AddShowDonationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_donations, :boolean, :default => true
  end
end