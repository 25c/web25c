class CreateUsers < ActiveRecord::Migration
  
  def up
    create_table :users do |t|
      t.string :uuid, :null => false
      t.string :email
      t.string :password_digest
      t.string :facebook_uid
      t.string :facebook_code
      t.string :facebook_access_token
      t.timestamps
    end
    ActiveRecord::Base.connection.execute 'CREATE UNIQUE INDEX "index_users_on_uuid" ON "users" (LOWER(uuid))'
    ActiveRecord::Base.connection.execute 'CREATE UNIQUE INDEX "index_users_on_email" ON "users" (LOWER(email))'
  end
  
  def down
    ActiveRecord::Base.connection.execute 'DROP INDEX "index_users_on_uuid"'
    ActiveRecord::Base.connection.execute 'DROP INDEX "index_users_on_email"'
    drop_table :users
  end
  
end
