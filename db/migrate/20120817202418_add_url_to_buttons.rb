class AddUrlToButtons < ActiveRecord::Migration
  def change
    add_column :buttons, :info_url, :string
  end
end
