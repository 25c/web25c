class Payment < ActiveRecord::Base
  
  require 'net/https'
  require 'rubygems'
  require 'builder'
  require 'socket'
  
  module State
    NEW = 0
    PROCESSING = 1
    PAID = 2
    REFUNDED = 3
    # TODO: add payment states if more steps
  end
  
  belongs_to :user
  
  validates :payment_type,
    :inclusion => {
      :in => %w(payin payout),
      :message => "%{value} is not a valid payment type"
    }
  
  attr_accessible :amount, :state, :payment_type
  
  before_create :generate_uuid
  
  def process
    # process payouts after 25c admin approval
    if self.payment_type == 'payin'
      if self.state == State::NEW or self.state == State::PROCESSING
        return true if self.update_attribute(:state, State::PAID)
      end
    elsif self.payment_type == 'payout'
    
   sandbox_url = "https://svcs.sandbox.paypal.com/AdaptivePayments/Pay"
   live_url = "https://svcs.paypal.com/AdaptivePayments/Pay"
   
   url = live_url

   #   This is a sandbox request data with sandboxed credentials
   #   request_data = {
   #      :API_USER => "corp10_1344372396_biz_api1.25c.com",
   #      :USER => "corp10_1344372396_biz@25c.com",
   #     :PWD => "1344372419",
   #      :SIGNATURE => "AFcWxV21C7fd0v3bYYYRCpSSRl31AjasVw9HF5loQn8PpkZelxreg.Nh",
   #     :APPID => "APP-80W284485P519543T",
   #    :AMT => "%.2f" % self.amount,
   #    :RETURNURL => "http://www.25c.com/home/payout/succeed",
   #     :CANCELURL => "http://www.25c.com/home/payout/fail"
   #  }

   # This is the live credentials for request data
      request_data = {
        :API_USER => "corp_api1.25c.com",
        :SENDER => "corp@25c.com",
        :PWD => "ABWF85B6K2NGBHZ9",
        :SIGNATURE => "A2GcOZdfyYPyC2hXDhVVJJnGE66vA6JqyJnYzOs2R7pbJrqhZ9aTfqM1",
        :APPID => "APP-9UL86141TG297463L",
        :ENDPOINT => "svcs.paypal.com",
        :AMT => "%.2f" % self.amount,
        :RETURNURL => "http://www.25c.com/home/payout/succeed",
        :CANCELURL => "http://www.25c.com/home/payout/fail"
     }
      post_data = ''

      builder = ::Builder::XmlMarkup.new :target => post_data, :indent => 2
      builder.instruct!
      builder.PayRequest do |x|
        x.requestEnvelope do |x|
          x.detailLevel 'ReturnAll'
        end
        x.clientDetails do |x|
          x.ipAddress local_ip
          x.deviceId ''
          x.applicationId request_data[:APPID]
          x.partnerName '25c'
        end
        x.senderEmail request_data[:SENDER]
        x.actionType 'PAY'
        x.feesPayer 'EACHRECEIVER'
        x.cancelUrl request_data[:CANCELURL]
        x.currencyCode 'USD'
        x.receiverList do |x|
          x.receiver do |x|
            x.amount request_data[:AMT]
            x.email self.user.paypal_email
          end
        end
        x.returnUrl request_data[:RETURNURL]
      end

      puts "url = #{url}"
      puts "post_data = #{post_data}"

      request = Net::HTTP::Post.new("/AdaptivePayments/Pay")
      request.body = post_data

      # request and response data format can be "NV" or "XML" or "JSON"
      headers = {
        "X-PAYPAL-REQUEST-DATA-FORMAT" => "XML",
        "X-PAYPAL-RESPONSE-DATA-FORMAT" => "XML",
        "X-PAYPAL-SECURITY-USERID" => request_data[:API_USER],
        "X-PAYPAL-SECURITY-PASSWORD" => request_data[:PWD],
        "X-PAYPAL-SECURITY-SIGNATURE" => request_data[:SIGNATURE],
        "X-PAYPAL-SERVICE-VERSION" => "1.1.0",
        "X-PAYPAL-APPLICATION-ID" => request_data[:APPID]
      }

      headers.each_pair {|k, v| request[k] = v}

      request.content_type = 'text/xml'

      # get a server handle
      port = 443
      http_server = Net::HTTP.new(request_data[:ENDPOINT], port)
      http_server.use_ssl = true

      # get the response XML
      res= http_server.start{|http| http.request(request)}.body

      puts "res = #{res}"
      
      if res.include? 'COMPLETE'
        self.update_attribute(:state, State::PAID)
        clicks = Click.where(:button_id => self.user.button_ids).find_all_by_state(Click::State::QUEUED)
        clicks.each{ |click| click.set_paid }
      end 

    end
  end
  
  private
  
  def generate_uuid
    self.uuid = UUID.new.generate(:compact)
  end
  
  def local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

end
