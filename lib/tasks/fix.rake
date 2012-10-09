namespace :fix do
  
  namespace :users do
    
    desc "Reconcile balance with click database- (note, not transaction safe, run only when all processes stopped)"
    task :balance => :environment do
      User.find_each do |user|
        user.update_attribute(:balance, user.clicks.where(:state => Click::State::DEDUCTED).sum(:amount))
        puts "#{user.id}: balance=#{user.balance}"
      end
    end
    
  end

end
