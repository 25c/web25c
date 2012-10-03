class CreateInvites < ActiveRecord::Migration
  def up
    create_table :invites do |t|
      t.string :uuid, :null => false
      t.integer :button_id, :null => false
      t.string :email
      t.integer :state, :default => 0, :null => false
      t.timestamps
    end
    
    # lookup index for uuids
    add_index :invites, :uuid
    
  end
  
  def down
    drop_table :invites
  end
  
end
