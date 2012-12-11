namespace :fix do
  
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
