class AddDwollaEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dwolla_email, :string
  end
end
