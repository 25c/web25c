# This is a generic BackgroundJob for executing any method on a model object:
#
# Resque.enqueue(BackgroundJob, <model name>, <primary key id>, <method to execute>)      
#
module BackgroundJob
  extend Heroku::ResqueScaler
  
  @queue = :background
            
  def self.perform(model_name, id, method)
    object = model_name.constantize.find_by_id(id)
    object.send(method)
  end
end