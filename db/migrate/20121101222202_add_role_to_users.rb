class AddRoleToUsers < ActiveRecord::Migration
  
  def up
    add_column :users, :role, :string, :null => false, :default => 'tipper'
    add_index :users, :facebook_uid, :unique => true
    execute 'DROP INDEX index_users_on_email'
    execute 'CREATE UNIQUE INDEX "index_users_on_email_and_role" ON "users" (LOWER(email), LOWER(role))'
  end
  
  def down
    remove_column :users, :role
    remove_index :users, :facebook_uid
    execute 'CREATE UNIQUE INDEX "index_users_on_email" ON "users" (LOWER(email))'
  end
  
end
