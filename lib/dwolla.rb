module Dwolla
  def self.endpoint=(endpoint)
    @@endpoint = endpoint
  end

  def self.endpoint
    @@endpoint
  end

  def self.user_agent=(user_agent)
    @@user_agent = user_agent
  end

  def self.user_agent
    @@user_agent
  end

  def self.debugging?
    !!@@debug
  end

  def self.debug=(debug)
    @@debug = debug
  end

  self.debug = false
  self.user_agent = "Dwolla Ruby Wrapper"
  self.endpoint = "https://www.dwolla.com/oauth/rest"
end

require 'faraday'
require 'multi_json'

require "#{File.dirname(__FILE__)}/dwolla/exceptions"
require "#{File.dirname(__FILE__)}/dwolla/response/parse_json"
require "#{File.dirname(__FILE__)}/dwolla/response/follow_redirects"
require "#{File.dirname(__FILE__)}/dwolla/response/guard_server_error"
require "#{File.dirname(__FILE__)}/dwolla/connection"
require "#{File.dirname(__FILE__)}/dwolla/client"
require "#{File.dirname(__FILE__)}/dwolla/transaction"
require "#{File.dirname(__FILE__)}/dwolla/funding_source"
require "#{File.dirname(__FILE__)}/dwolla/user"
require "#{File.dirname(__FILE__)}/dwolla/version"