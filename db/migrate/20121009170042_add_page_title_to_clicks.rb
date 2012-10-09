class AddPageTitleToClicks < ActiveRecord::Migration
  
  def connection
    ActiveRecord::Base.establish_connection("#{Rails.env}_data").connection
  end
  
  def change
    add_column :clicks, :page_title, :string
  end
  
end
