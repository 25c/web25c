# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# execute postgres specific changes not supported by rails migration/schema syntax
ActiveRecord::Base.connection.execute 'CREATE UNIQUE INDEX "index_users_on_uuid" ON "users" (LOWER(uuid))'
ActiveRecord::Base.connection.execute 'CREATE UNIQUE INDEX "index_users_on_email" ON "users" (LOWER(email))'
ActiveRecord::Base.connection.execute 'CREATE UNIQUE INDEX "index_users_on_nickname" ON "users" (LOWER(nickname))'
ActiveRecord::Base.connection.execute 'CREATE UNIQUE INDEX "index_buttons_on_uuid" ON "buttons" (LOWER(uuid))'
ActiveRecord::Base.connection.execute 'CREATE UNIQUE INDEX "index_payments_on_uuid" ON "payments" (LOWER(uuid))'
