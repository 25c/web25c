module ApplicationHelper
  
  def image_url(source)
    return "#{request.protocol}#{request.host_with_port}#{source}" if source.start_with?('/')
    source
  end
  
  def auth_google_oauth2_path
    path = "/auth/google_oauth2"
    if @button_id
      state = "button_id=#{@button_id}"
      state = "#{state}&referrer=#{@referrer}" if @referrer
      path = "#{path}?state=#{Rack::Utils.escape(state)}"
    end
  end
  
  def age(datetime)
    diff = Time.now.utc - datetime.utc
    case
    when diff < 60
      t('application_helper.age.now')
    when diff < 1.hour
      t('application_helper.age.minutes', :minutes => number_with_precision(diff/1.minute, :precision => 0))
    when diff < 24.hour
      t('application_helper.age.hours', :hours => number_with_precision(diff/1.hour, :precision => 0))
    when diff < 1.week
      t('application_helper.age.days', :days => number_with_precision(diff/1.day, :precision => 0))
    when diff < 1.month
      t('application_helper.age.weeks', :weeks => number_with_precision(diff/1.week, :precision => 0))
    when diff < 1.year
      t('application_helper.age.months', :months => number_with_precision(diff/1.month, :precision => 0))
    else
      t('application_helper.age.years', :years => number_with_precision(diff/1.year, :precision => 1))
    end
  end
  
  class BraintreeFormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TagHelper

    def initialize(object_name, object, template, options, proc)
      super
      @braintree_params = @options[:params]
      @braintree_errors = @options[:errors]
    end

    def fields_for(record_name, *args, &block)
      options = args.extract_options!
      options[:builder] = BraintreeFormBuilder
      options[:params] = @braintree_params && @braintree_params[record_name]
      options[:errors] = @braintree_errors && @braintree_errors.for(record_name)
      new_args = args + [options]
      super record_name, *new_args, &block
    end

    def text_field(method, options = {})
      has_errors = @braintree_errors && @braintree_errors.on(method).any?
      field = super(method, options.merge(:value => determine_value(method)))
      result = content_tag("div", field, :class => has_errors ? "fieldWithErrors" : "")
      result.safe_concat validation_errors(method)
      result
    end

    protected

    def determine_value(method)
      if @braintree_params
        @braintree_params[method]
      else
        nil
      end
    end

    def validation_errors(method)
      if @braintree_errors && @braintree_errors.on(method).any?
        @braintree_errors.on(method).map do |error|
          content_tag("div", ERB::Util.h(error.message), {:style => "color: red;"})
        end.join
      else
        ""
      end
    end
  end
end

