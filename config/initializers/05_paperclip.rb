Paperclip.interpolates :uuid do |attachment, style|
  attachment.instance.uuid
end

if Rails.env.development?
  Paperclip::Attachment.default_options[:default_url] = "http://i50.tinypic.com/5y6ljo.png"
  Paperclip::Attachment.default_options[:url] = "/s3/:class/:attachment/:uuid/:style.:extension"
else
  Paperclip::Attachment.default_options[:default_url] = "http://i50.tinypic.com/5y6ljo.png"
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = AWS_SETTINGS
  Paperclip::Attachment.default_options[:bucket] = AWS_SETTINGS[:bucket]
  Paperclip::Attachment.default_options[:url] = ":s3_path_url"
  Paperclip::Attachment.default_options[:path] = ":class/:attachment/:uuid/:style.:extension"
end