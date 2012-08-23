module Dwolla
  module Response
    class InternalServerError < Faraday::Error::ClientError
      attr_reader :response
    
      def initialize(response)
        super "Internal Server Error"
        @response = response
      end
    end
    class AccessDeniedError < Faraday::Error::ClientError
      attr_reader :response
    
      def initialize(response)
        super "Access was denied."
        @response = response
      end
    end
  
    class GuardServerError < Faraday::Response::Middleware
      def on_complete(env)
        if env[:status] == 500
          if env[:body].match /Access is denied/
            raise AccessDeniedError, env[:body]
          else
            raise InternalServerError, env[:body]
          end
        end
      end
    end
  end
end
