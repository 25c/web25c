class AddBalanceColumnsToUsers < ActiveRecord::Migration
  
  def up
    ActiveRecord::Base.connection.execute 'ALTER TABLE users ALTER balance TYPE INTEGER USING (balance/-1000000)::INTEGER'
    rename_column :users, :balance, :balance_paid
    add_column :users, :balance_free, :integer, :null => false, :default => 0
    add_column :users, :total_given, :integer, :null => false, :default => 0
  end
  
  def down
    rename_column :users, :balance_paid, :balance
    ActiveRecord::Base.connection.execute 'ALTER TABLE users ALTER balance TYPE BIGINT USING balance::BIGINT*-1000000'
    remove_column :users, :balance_free
    remove_column :users, :total_given
  end
  
end
