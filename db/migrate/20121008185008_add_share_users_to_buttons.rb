class AddShareUsersToButtons < ActiveRecord::Migration
  def change
    add_column :buttons, :share_users, :string, :default => ''
  end
end
