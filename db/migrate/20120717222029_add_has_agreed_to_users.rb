class AddHasAgreedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_agreed, :boolean, :default => false
  end
end