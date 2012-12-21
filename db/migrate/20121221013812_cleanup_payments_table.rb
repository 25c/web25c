class CleanupPaymentsTable < ActiveRecord::Migration
  def change
    connection.execute "DELETE FROM payments;"
    remove_column :payments, :uuid
    remove_column :payments, :state
    remove_column :payments, :payment_type
    remove_column :payments, :transaction_id
    add_column :payments, :transaction_id, :string, :null => false
    remove_column :payments, :amount
    add_column :payments, :amount_value, :decimal, :null => false
    remove_column :payments, :balance_paid
    add_column :payments, :amount_points, :integer, :null => false
  end
end
