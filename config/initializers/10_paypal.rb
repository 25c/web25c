PAYPAL_SETTINGS = HashWithIndifferentAccess.new(YAML::load(File.open("#{Rails.root}/config/paypal.yml"))[Rails.env])
PAYPAL_ACCOUNT = 'corp10_1344372396_biz@25c.com'
ActiveMerchant::Billing::Base.mode = :test