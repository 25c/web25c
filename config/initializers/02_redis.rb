if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new
end

if ENV["REDISTOGO_DATA_URL"]
  uri = URI.parse(ENV["REDISTOGO_DATA_URL"])
  DATA_REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  DATA_REDIS = Redis.new
end


# Configure resque
Resque.redis = REDIS
# Make server endpoint available
require 'resque/server'
