class AddIsNewToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_new, :boolean, :default => true
  end
end