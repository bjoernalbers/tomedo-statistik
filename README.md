# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Development

### Setup

Install Ruby 2.5 and PostgreSQL 9.

You might chose a ruby version manager, like
[rvm](https://rvm.io),
[rbenv](https://github.com/rbenv/rbenv) or
[chruby](https://github.com/postmodern/chruby) to select your desired ruby version.
I'm using chruby.

Then clone this repository and `cd` into it:

    git clone git@github.com:bjoernalbers/tomedo-statistik.git
    cd tomedo-statistik

Run `bundle install` to install all required gems.
If you don't have bundler then you can install it with `gem install bundler`.

On the tomedo server dump the production database into a file:

    /Library/PostgreSQL/9.2/bin/pg_dump -U postgres -Fc -f /tmp/tomedo_live.fc tomedo_live

This might take 5 to 10 minutes depending on your database size.
Then on your development machine copy the created file from the server (your
hostname / ip address will be different!):

    scp fredegar:/tmp/tomedo_live.fc .

Import the database on your development machine:

    createdb tomedo_entwicklung
    pg_restore -x -O -d tomedo_entwicklung db/tomedo_live.fc

Again this may take 5 to 10 minutes.

Then start the server with `bin/rails s`.
Done.

## Production

### Operating System and hardware

The production server should run an up-to-date version of openSUSE Tumbleweed.
A virtual machine with 1 or 2 GB of RAM, 1 processor and 10 or 20 GB of hard
disk space should be enough.

### Setup

These are the steps to setup the production environment.
The commands have to be run on the remote server.

Install Ruby 2.5 if not already present:

    zypper in -y ruby2.5

Install bundler:

    gem install bundler

I also had to symlink bundler's binaries because they weren't in my `PATH`
(your binary paths may vary depending on the ruby and bundler versions;
find out with `gem which bundler`):

    ln -s /usr/lib64/ruby/gems/2.5.0/gems/bundler-1.16.4/exe/bundle /usr/local/bin
    ln -s /usr/lib64/ruby/gems/2.5.0/gems/bundler-1.16.4/exe/bundler /usr/local/bin

Install development packages so that you can compile native gem-extensions:

    zypper in -y -t pattern devel_C_C++

Install PostgreSQL with development headers (required for the pg gem):

    zypper in -y postgresql96 postgresql96-devel
    # NOTE: Manually symlink `pg_config` because it doesn't exist after
    # installing `postgresql96-devel`, possibly due to a bug.
    ln -s /usr/lib/postgresql96/bin/pg_config /usr/local/bin/

Install further development dependencies in order to build gems:

    zypper in -y ruby2.5-devel
    zypper in -y libxml2-2 libxml2-devel # Required for nokogiri
    zypper in -y libxslt-devel libxslt1  # Required for nokogiri

Install git:

    zypper in -y git

Then change the firewall to allow connections to http and restart it:

    firewall-cmd --permanent --add-service=http
    systemctl restart firewalld.service

Then create the directories for deployment:

    mkdir -p /data/tomedo-statistik/shared/config

**The following steps have to be performed on your development machine!**

Copy your public SSH-key form your development machine to the production
server, which can be done manually or via `ssh-copy-id` (install via
[mac homebrew](https://brew.sh)).
I use `ssh-copy-id` for that:

    brew install ssh-copy-id
    ssh-copy-id root@tomedo-statistik

And then on your development machine upload the master key to production:

    scp config/master.key root@tomedo-statistik:/data/tomedo-statistik/shared/config

(NOTE: Only I have the master key because it shouldn't be in version control!)

### Deployment

After the setup you can deploy the code with...

    bundle exec cap production deploy

Don't forget to push your changes to github *before* deployment!
