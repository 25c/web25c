web: bundle exec thin start -p $PORT -e $RAILS_ENV
ssl: bundle exec thin start -p $SSL_PORT -e $RAILS_ENV --ssl
worker: bundle exec rake resque:work