class AddProfileColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :nickname, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :about, :text
    add_attachment :users, :picture
    
    execute 'CREATE UNIQUE INDEX "index_users_on_nickname" ON "users" (LOWER(nickname))'        
  end
  
  def down
    remove_column :users, :nickname
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :about
    remove_attachment :users, :picture    
  end
end
