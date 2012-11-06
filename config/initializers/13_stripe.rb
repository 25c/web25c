STRIPE_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/stripe.yml"))[Rails.env])

