AWS_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/aws.yml"))[Rails.env])
