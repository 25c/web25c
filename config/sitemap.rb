require 'rubygems'
require 'sitemap_generator'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.25c.com"

SitemapGenerator::Sitemap.create do
  add '/', :priority => 1
  add '/contact_us'
  
  add '/about', :priority => 0.7
  add '/faq', :priority => 0.7
  add '/fees', :priority => 0.5
  add '/terms', :priority => 0.3
  add '/privacy', :priority => 0.3
  
  User.find_each do |user|
    unless user.nickname.blank?
      add '/' + user.nickname, :lastmod => user.updated_at, :priority => 0.5
    end
  end
  
  add '/sign-in', :priority => 0.7
  add '/sign-out', :priority => 0.1
  
end