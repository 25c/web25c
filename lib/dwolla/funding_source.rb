module Dwolla
  class FundingSource
    attr_accessor :id, :name, :type, :verified
    def verified?
      !!verified
    end
    
    def self.from_json(options)
      source = FundingSource.new
      source.id = options["Id"]
      source.name = options["Name"]
      source.type = options["Type"]
      source.verified = options["Verified"]
      source
    end
  end
end

