class AddAutoRefillToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auto_refill, :boolean, :default => true
  end
end