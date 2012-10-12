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
  
  namespace :clicks do
    desc "Sets receiver user for clicks before revenue share schema changes"
    task :receiver => :environment do
      Click.where(:parent_click_id => nil).find_each do |click|
        if click.receiver_user_id.nil? and click.clicks.empty?
          if click.button.nil?
            click.destroy
          else
            click.update_attribute(:receiver_user_id, click.button.user_id)
          end
        end
      end
    end
  end

end
