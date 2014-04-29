namespace :update do
  desc 'Update Current Repo from Github'
  task :from_github do
   `git remote add github git@github.com:Publiss/Publiss-Whitelabel-iOS.git`
   `git remote update`
   `git pull github develop`
   `git remote remove github`
  end
end
