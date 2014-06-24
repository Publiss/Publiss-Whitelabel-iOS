namespace :update do
	desc 'Update Current Repo from Github'
	task :from_github, [:branch] do |t, args|
		args.with_defaults(:branch => "develop")
		puts "adding github remote git@github.com:Publiss/Publiss-Whitelabel-iOS.git"
		`git remote add github git@github.com:Publiss/Publiss-Whitelabel-iOS.git`
		`git remote update`
		puts "git checkout #{args.branch}"
		`git checkout #{args.branch}`
		`git pull github #{args.branch}`
		puts "Cleaning up"
		`git remote remove github`
	end
end