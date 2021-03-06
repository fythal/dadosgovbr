# Script retirado de http://f3internet.com/articles/2010/06/18/deploying-static-sites-with-capistrano/

set :application, "dadosgovbr" # Application name.
set :location, "200.198.213.70" # Web server url.
set :user, "operador" # Remote user name. Must be able to log in via SSH.
set :port, 3569 # SSH port. Only required if non default ssh port used.
set :use_sudo, false # Remove or set the true if all commands should be run through sudo.

set :local_user, "alegomes" # Local user name.

set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :copy # Copy the files across as an archive rather than using Subversion on the remote machine.
set :copy_dir, "/tmp/capistrano" # Directory in which the archive will be created. Defaults to /tmp. Note that I had problems with /tmp because on my machine it's on a different partition to the rest of my filesystem and hence a hard link could not be created across devices.
set :copy_remote_dir, "/tmp/capistrano" # Directory on the remote machine where the archive will be copied. Defaults to /tmp.

# Git config (http://help.github.com/deploy-with-capistrano/)
default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :repository, "git@github.com:WesleyRocha/dadosgovbr.git"  # Your clone URL
set :scm, "git"
ssh_options[:forward_agent] = true

#set :copy_cache, "#{copy_dir}/#{application}" # Directory in which the local copy will reside. Defaults to /tmp/#{application}. Note that copy_dir must not be the same as (nor inside) copy_cache and copy_cache must not exist before deploy:cold.
#set :copy_exclude, [".svn", "**/.svn"] # Prevent Subversion directories being copied across.

role :app, location
role :web, location
role :db,  location, :primary => true

# Override default tasks which are not relevant to a non-rails app.
namespace :deploy do
  task :migrate do
    puts "    not doing migrate because not a Rails application."
  end
  task :finalize_update do
    puts "    not doing finalize_update because not a Rails application."
  end
  task :start do
    puts "    not doing start because not a Rails application."
  end
  task :stop do 
    puts "    not doing stop because not a Rails application."
  end
  task :restart do
    puts "    not doing restart because not a Rails application."
  end

	desc <<-DESC
	  Theme deploy
	DESC
	task :theme do
		print "    deploying CKAN theme"
		run "cp -R /home/operador/dadosgovbr/current/ckan-theme/* /home/operador/pyenv/src/ckanext-dadosgovbr/ckanext/dadosgovbr/theme/"
	end
end

# Custom tasks for our hosting environment.
namespace :remote do

  desc <<-DESC
    Create directory required by copy_remote_dir.
  DESC
  task :create_copy_remote_dir, :roles => :app do
    print "    creating #{copy_remote_dir}.\n"
    run "mkdir -p #{copy_remote_dir}"
  end

  desc <<-DESC
    Create a symlink to the application.
  DESC
  task :create_symlink, :roles => :web do
    print "    creating symlink ~/public_html/#{application} -> #{current_path}. Configure your server to use this link.\n"
    run "ln -s #{current_path} ~/public_html/#{application}"
  end

end

# Custom tasks for our local machine.
namespace :local do
  
  desc <<-DESC
    Create directory required by copy_dir.
  DESC
  task :create_copy_dir do
    print "    creating #{copy_dir}.\n"
    system "mkdir -p #{copy_dir}"
  end

end

# Callbacks.
before 'deploy:setup', 'local:create_copy_dir', 'remote:create_copy_remote_dir'
after 'deploy' , 'deploy:theme'