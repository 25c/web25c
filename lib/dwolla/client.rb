module Dwolla
  class Client
    include Dwolla::Connection

    def initialize(client, secret)
      @client, @secret = client, secret
    end

    def user(id)
      user_attributes_hash = get("users/#{id}")
      User.new(user_attributes_hash)
    end

    def auth_url(redirect_uri=nil, scope='send|transactions|balance|request|contacts|accountinfofull|funding')
        params = {
            'scope' => scope,
            'response_type' => 'code',
            'client_id' => @client
        }
        unless redirect_uri.nil?
            params['redirect_uri'] = redirect_uri
        end
        querystring = params.map{|k,v| "#{CGI.escape(k)}=#{CGI.escape(v)}"}.join("&")

        return 'https://www.dwolla.com/oauth/v2/authenticate?' + querystring
    end
    
    def request_token(code, redirect_uri=nil)
        params = {
            'client_id' => @client,
            'client_secret' => @secret,
            'grant_type'    => 'authorization_code',
            'code'          => code
        }
        unless redirect_uri.nil?
            params['redirect_uri'] = redirect_uri
        end

        resp = get('https://www.dwolla.com/oauth/v2/token', params)

        return resp['access_token']
    end

    private

      def auth_params
        { :client_id => @client, :client_secret => @secret }
      end
   end
end
