class ModifyUserBalance < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute 'UPDATE users SET balance=balance*-25'
  end

  def down
    ActiveRecord::Base.connection.execute 'UPDATE users SET balance=balance/-25'
  end
end
