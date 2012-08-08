class CreatePayments < ActiveRecord::Migration

  def up
    #create table for payments
    create_table :payments do |t|
      t.string :uuid, :null => false
      t.integer :user_id, :null => false
      t.string :user_paypal_email
      t.integer :amount
      t.integer :state, :default => 0, :null => false
      t.string :payment_type, :null => false
      t.timestamps
    end
    
    # lookup index for payments on postgres
    add_index :payments, :user_id
    execute 'CREATE UNIQUE INDEX "index_payments_on_uuid" ON "payments" (LOWER(uuid))'
  end
  
  def down
    drop_table :payments
  end
  
end
