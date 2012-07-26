class AddPictureToButtons < ActiveRecord::Migration
  def change
    add_column :buttons, :youtube_id, :string
    add_attachment :buttons, :picture
  end
end