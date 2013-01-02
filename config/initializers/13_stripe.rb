STRIPE_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/stripe.yml"))[Rails.env])
Stripe.api_key = STRIPE_SETTINGS[:secret_key]
