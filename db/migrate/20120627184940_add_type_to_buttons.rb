class AddTypeToButtons < ActiveRecord::Migration
  def change
    add_column :buttons, :code_type, :string
    Button.update_all ["code_type = ?", 'javascript']
    Button.update_all ["size = ?", 'btn_large']
  end
end