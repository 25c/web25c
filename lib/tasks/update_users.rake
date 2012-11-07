namespace :users do
  desc "Set unregistered users to suspended if initial period is exceeded."
  task :suspend_unregistered => :environment do
    users = User.where(:has_valid_card => false, :is_suspended => false)
    for user in users
      if user.created_at < Time.now - 3600
        user.editing = true
        user.is_suspended = true
        user.save!
        user.editing = false
        # TODO: Send email notification about suspended accounts
      end
    end
  end
end