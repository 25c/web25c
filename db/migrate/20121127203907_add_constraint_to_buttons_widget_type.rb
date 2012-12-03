class AddConstraintToButtonsWidgetType < ActiveRecord::Migration
  
  def up
    ActiveRecord::Base.connection.execute "UPDATE buttons SET widget_type='fan_belt' WHERE widget_type IS NULL"
    change_column :buttons, :widget_type, :string, :null => false
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
  
end
