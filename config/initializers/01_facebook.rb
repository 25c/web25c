FACEBOOK_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/facebook.yml"))[Rails.env])
