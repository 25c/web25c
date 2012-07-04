GOOGLE_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/google.yml"))[Rails.env])
