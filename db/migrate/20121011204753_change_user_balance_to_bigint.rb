class ChangeUserBalanceToBigint < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute 'ALTER TABLE users ALTER balance TYPE BIGINT USING balance::BIGINT*1000000'
    ActiveRecord::Base.connection.execute 'ALTER TABLE payments ALTER amount TYPE BIGINT USING amount::BIGINT*1000000'
  end

  def down
    ActiveRecord::Base.connection.execute 'ALTER TABLE users ALTER balance TYPE INTEGER USING CAST(balance/1000000 AS INTEGER)'
    ActiveRecord::Base.connection.execute 'ALTER TABLE payments ALTER amount TYPE INTEGER USING CAST(amount/1000000 AS INTEGER)'
  end
end
