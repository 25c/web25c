# monkey-patch the Curl library to have a convenience method for downloading files
module Curl
  class Easy
    def self.download_file(url, referer_url = nil)            
      filename = "#{Rails.root}/tmp/#{SecureRandom.hex}_#{url.split(/\?/).first.split(/\//).last}"
      result = Curl::Easy.download(url, filename) do |curl|
        curl.useragent = "Mozilla/5.0 (Windows NT 5.1; rv:8.0) Gecko/20100101 Firefox/8.0"
        curl.headers["Referer"] = referer_url if referer_url
        curl.follow_location = true
      end
      return File.new(filename) if File.exists?(filename)
      return nil
    end
  end  
end
