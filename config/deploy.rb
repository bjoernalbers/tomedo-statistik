# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :application, 'tomedo-statistik'
set :repo_url, 'git@github.com:bjoernalbers/tomedo-statistik.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/data/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
append :linked_files, 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

after "deploy", "rails:restart"

namespace :rails do
  def systemd_config_source
    "#{release_path}/config/rails.service"
  end

  def systemd_config_destination
    '/etc/systemd/system/rails.service'
  end

  desc 'Restart the rails service'
  task restart: :setup_systemd do
    on roles(:app) do
      execute 'systemctl restart rails.service'
    end
  end

  desc 'Setup systemd for rails'
  task setup_systemd: :check_systemd_config do
    on roles(:app) do
      execute "ln -sf '#{systemd_config_source}' '#{systemd_config_destination}'"
      # Always reload systemd in case the rails service config has changed.
      execute 'systemctl daemon-reload'
      execute 'systemctl enable rails.service'
    end
  end

  desc 'Check if the systemd config is present'
  task :check_systemd_config do
    on roles(:app) do
      execute "test -f '#{systemd_config_source}'"
    end
  end
end
