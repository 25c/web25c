class AddWebsiteUrlToButtons < ActiveRecord::Migration
  def change
    add_column :buttons, :website_url, :string
  end
end
