class CreateUsers < ActiveRecord::Migration
  
  def change
    
    create_table :users do |t|
      t.string :uuid, :null => false
      t.string :email
      t.string :password_digest
      t.string :facebook_uid
      t.string :facebook_code
      t.string :facebook_access_token
      t.timestamps
    end
    add_index :users, :uuid, :unique => true
    
  end
  
end
