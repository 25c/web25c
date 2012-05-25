class CreateContentsTable < ActiveRecord::Migration
  def up
    create_table :contents do |t|
      t.string :name, :null => false
      t.string :uuid, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
    add_index :contents, :user_id
    execute 'CREATE UNIQUE INDEX "index_contents_on_uuid" ON "contents" (LOWER(uuid))'
  end
  def down
    drop_table :contents
  end
end
