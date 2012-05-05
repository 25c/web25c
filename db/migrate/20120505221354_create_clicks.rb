class CreateClicks < ActiveRecord::Migration
  
  def change
    create_table :clicks do |t|
      t.integer :publisher_user_id, :null => false
      t.integer :user_id, :null => false
      t.text :url
      t.datetime :created_at
    end
    add_index :clicks, :publisher_user_id
    add_index :clicks, :user_id
  end
  
end
