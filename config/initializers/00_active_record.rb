# monkey-patch ActiveRecord::Base to include case-insensitive finders
class ActiveRecord::Base
  # the new method has to be a class method
  # note that it refers to the default implementation as 
  # method_missing_without_case_insensitive_finders
  def self.method_missing_with_case_insensitive_finders(method_called, *args, &block)
    match = method_called.to_s.match(/^find_by_(\w+)_ci$/)
    if match && respond_to?("find_by_#{match[1]}")
      find(:first, :conditions => ["lower(#{match[1]}) = lower(?)", *args[0]])
    else
      method_missing_without_case_insensitive_finders(method_called, *args, &block)
    end
  end
 
  # method_missing is a class method, and this is how class methods are aliased
  class << self
    alias_method_chain(:method_missing, :case_insensitive_finders)
  end
end
