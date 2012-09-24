class AddPledgeMessageToButtons < ActiveRecord::Migration
  def change
    add_column :buttons, :pledge_message, :string, :default => ''
  end
end
