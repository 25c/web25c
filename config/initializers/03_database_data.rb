if ENV["DATABASE_DATA_URL"]
  uri = URI.parse(ENV["DATABASE_DATA_URL"])
  ActiveRecord::Base.configurations["#{Rails.env}_data"] = {
    "adapter" => "postgresql",
    "host" => uri.host,
    "username" => uri.user,
    "password" => uri.password,
    "database" => uri.path[1..-1],
    "port" => uri.port
  }
end
