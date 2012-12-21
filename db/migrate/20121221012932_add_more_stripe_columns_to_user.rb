class AddMoreStripeColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :stripe_type, :string
    add_column :users, :stripe_exp_month, :integer
    add_column :users, :stripe_exp_year, :integer
  end
end
