module Dwolla
  class Transaction
    include Dwolla::Connection
    @test_mode = false
    def self.test_mode
      @test_mode
    end
    def self.test_mode=(m)
      @test_mode = m
    end

    ENDPOINTS = { :send => 'transactions/send',
                  :request => 'transactions/request' }
    TEST_ENDPOINTS = { :send => 'testapi/send',
                  :request => 'testapi/request' }

    attr_accessor :origin, :destination, :destination_type, :type, :amount, :pin, :id, :source, :source_type, :description, :funds_source

    def initialize(attrs = {})
      attrs.each do |key, value|
        send("#{key}=".to_sym, value)
      end
    end

    def execute
      if self.class.test_mode
        end_point = TEST_ENDPOINTS[type]
      else
        end_point = ENDPOINTS[type]
      end
      self.id = post(end_point, to_payload)
    end

    private

      def auth_params
        { :oauth_token => origin.oauth_token }
      end

      def to_payload
        payload = {
          :amount => amount,
          :pin => pin
        }
        payload[:destinationId] = destination if destination
        payload[:destinationType] = destination_type if destination_type
        payload[:sourceId] = source if source
        payload[:sourceType] = source_type if source_type
        payload[:notes] = description if description
        payload[:fundsSource] = funds_source if funds_source

        payload
      end
  end
end
