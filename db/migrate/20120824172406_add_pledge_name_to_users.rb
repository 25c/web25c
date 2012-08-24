class AddPledgeNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pledge_name, :string
    add_column :users, :has_seen_receive_page, :boolean, :default => false
  end
end