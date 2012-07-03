class UpdateOutdatedButtonSize < ActiveRecord::Migration
  def up
    sizes = ['btn-large', 'btn-medium', 'btn-small', 'icon-large', 'icon-medium', 'icon-small']
    Button.where("size NOT IN (?)", sizes).update_all(:size => 'btn-large')
  end

  def down
  end
end