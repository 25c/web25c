class CreateButtons < ActiveRecord::Migration
  def up
    create_table :buttons do |t|
      t.string :uuid, :null => false
      t.integer :user_id, :null => false
      t.string :size
      t.string :title
      t.text :description
      t.timestamps
    end
    add_index :buttons, :user_id
    execute 'CREATE UNIQUE INDEX "index_buttons_on_uuid" ON "buttons" (LOWER(uuid))'
  end
  def down
    drop_table :buttons
  end
end
