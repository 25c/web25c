require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

task "resque:prune_all_workers" => :environment do
  all_workers = Resque::Worker.all
  all_workers.each do |worker|
    puts "Pruning worker: #{worker}"
    worker.unregister_worker
  end  
end