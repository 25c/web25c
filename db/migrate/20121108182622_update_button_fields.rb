class UpdateButtonFields < ActiveRecord::Migration
  def change
    add_column :buttons, :widget_type, :string
    add_column :buttons, :additional_parameters, :string, :default => ''
    remove_column :buttons, :code_type
    remove_column :buttons, :size
    remove_column :buttons, :info_url
    remove_column :buttons, :youtube_id
    remove_column :buttons, :picture_file_name
    remove_column :buttons, :picture_content_type
    remove_column :buttons, :picture_file_size
    remove_column :buttons, :picture_updated_at
  end
end