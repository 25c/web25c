PAYPAL_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/paypal.yml"))[Rails.env])
if Rails.env.production?
  ActiveMerchant::Billing::Base.mode = :production
else
  ActiveMerchant::Billing::Base.mode = :test
end
