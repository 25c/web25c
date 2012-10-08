class CreateButtons < ActiveRecord::Migration
  def up
    
    # create a table for buttons
    create_table :buttons do |t|
      t.string :uuid, :null => false
      t.integer :user_id, :null => false
      t.string :size
      t.string :title
      t.text :description
      t.timestamps
    end
    
    # lookup index for buttons on postgres
    add_index :buttons, :user_id
    execute 'CREATE UNIQUE INDEX "index_buttons_on_uuid" ON "buttons" (LOWER(uuid))'
    
    # drop no longer needed contents table
    drop_table :contents
    
    # create a new button for each user
    User.all.each do |user|
      user.buttons.create(:size => "large")
    end
  end
  def down
    drop_table :buttons
    execute 'DROP INDEX "index_buttons_on_uuid"'
  end
end
