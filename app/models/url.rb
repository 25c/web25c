class Url < ActiveRecord::Base
  establish_connection "#{Rails.env}_data"

  def host
    @uri ||= URI.parse(self.url)
    @uri.host
  end
  
end
