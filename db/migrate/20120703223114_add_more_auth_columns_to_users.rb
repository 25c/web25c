class AddMoreAuthColumnsToUsers < ActiveRecord::Migration
  
  def change
    add_column :users, :twitter_uid, :string
    add_column :users, :twitter_username, :string
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_token_secret, :string
    add_index :users, :twitter_uid, :unique => true
    
    add_column :users, :google_uid, :string
    add_column :users, :google_token, :string
    add_column :users, :google_refresh_token, :string
    add_index :users, :google_uid, :unique => true
  end
  
end
