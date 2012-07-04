TWITTER_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/twitter.yml"))[Rails.env])
