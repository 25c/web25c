# Be sure to restart your server when you modify this file.

Web25c::Application.config.session_store :cookie_store, key: '_web25c_session', :domain => :all

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Web25c::Application.config.session_store :active_record_store

# monkey-patch the SignedCookieJar to serialize its data using JSON
module ActionDispatch
  class Cookies
    class SignedCookieJar < CookieJar #:nodoc:
      def initialize(parent_jar, secret)
        ensure_secret_secure(secret)
        @parent_jar = parent_jar
        @verifier   = ActiveSupport::MessageVerifier.new(secret, :serializer => JSON)
      end
    end
  end
end

# monkey-patch base Object class so it can be serialized using JSON
class Object
  def to_json(*a)
    {
      'json_class'   => self.class.name,
      'data'         => ::Base64.strict_encode64(Marshal.dump(self))
    }.to_json(*a)
  end
  
  def self.json_create(o)
    Marshal.load(::Base64.decode64(*o['data']))
  end
end
