class ChangePaymentTable < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute 'ALTER TABLE payments ALTER amount TYPE NUMERIC USING (amount/1000000)::INTEGER'
    add_column :payments, :balance_paid, :integer, :null => false, :default => 0
    add_column :payments, :currency, :string, :null => false, :default => 'usd'
    ActiveRecord::Base.connection.execute 'ALTER TABLE payments ALTER balance_paid DROP DEFAULT'
    ActiveRecord::Base.connection.execute 'ALTER TABLE payments ALTER currency DROP DEFAULT'
  end
  
  def down
    ActiveRecord::Base.connection.execute 'ALTER TABLE payments ALTER amount TYPE BIGINT USING amount::BIGINT*1000000'
    remove_column :payments, :balance_paid
    remove_column :payments, :currency
  end
end
