class AddAchColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ach_name, :string
    add_column :users, :ach_account_number, :string
    add_column :users, :ach_routing_number, :string
    add_column :users, :ach_type, :string, :default => 'checking', :null => false
  end
end
