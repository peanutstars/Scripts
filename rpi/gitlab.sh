#!/bin/bash
# PStars - https://github.com/peanutstars/Scripts
#
# This is based from :
#  http://stackoverflow.com/questions/19606735/raspberry-pi-and-gitlab
#  https://gitlab.com/gitlab-org/gitlab-ce/blob/7-7-stable/doc/install/installation.md

DIR_CUR=`pwd`
SWAPFILE=/swapfile
SWAP_BS=1024
SWAP_COUNT=1048576
FgNeedSwap=0

fFSize() {
	ls -al $1 | awk -F\  '{ print $5 }'
}

fMkSwapFile() {
	sudo dd if=/dev/zero of=$SWAPFILE bs=$SWAP_BS count=$SWAP_COUNT
	sudo mkswap $SWAPFILE && sudo chmod 0600 $SWAPFILE && sudo swapon $SWAPFILE
}
fAddGitUser() {
	if [ ! -e "/home/git" ] ; then
		sudo adduser --disabled-login --gecos 'GitLab' git
		sudo rm -rf /home/git/* && sudo rm -rf /home/git/.*
	fi
}
fAddFstab() {
	FgSWAP=`cat /etc/fstab | grep $SWAPFILE`
	if [ -z "$FgSWAP" ] ; then
		sudo SWAPFILE=$SWAPFILE sh -c 'echo "$SWAPFILE none swap defaults 0 0" >> /etc/fstab'
	fi
}

fPackage() {
	for PKG in build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev \
	libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall \
	libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate python-docutils \
	pkg-config cmake libkrb5-dev
	do
		sudo apt-get install -y $PKG
	done
	sudo apt-get install -y git-core
	sudo apt-get install -y git-svn
}
fRuby() {
	DIR_RUBY=/tmp/ruby
	[ -e "$DIR_RUBY" ] && rm -rf $DIR_RUBY
	mkdir $DIR_RUBY && cd $DIR_RUBY
	curl -L --progress http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz | tar xz
	cd ruby-2.1.5
	./configure --disable-install-rdoc
	make -j4
	sudo make install
	sudo gem install bundler --no-ri --no-rdoc
	cd $DIR_CUR
}
fDatabase() {
	for PKG in postgresql postgresql-client libpq-dev
	do
		sudo apt-get install -y $PKG
	done
	sudo -u postgres psql -d template1 <<EOF
CREATE USER git CREATEDB;
CREATE DATABASE gitlabhq_production OWNER git;
\q
EOF
	sudo -u git -H psql -d gitlabhq_production <<EOF
\q
EOF
}
fRedis() {
	sudo apt-get install -y redis-server
	sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.orig

	sed 's/^port .*/port 0/' /etc/redis/redis.conf.orig | sudo tee /etc/redis/redis.conf
	echo 'unixsocket /var/run/redis/redis.sock' | sudo tee -a /etc/redis/redis.conf
	echo 'unixsocketperm 770' | sudo tee -a /etc/redis/redis.conf
	mkdir /var/run/redis
	sudo chown redis:redis /var/run/redis
	sudo chmod 755 /var/run/redis
	if [ -d /etc/tmpfiles.d ]; then
		echo 'd  /var/run/redis  0755  redis  redis  10d  -' | sudo tee -a /etc/tmpfiles.d/redis.conf
	fi
	sudo service redis-server restart
	sudo usermod -aG redis git
}
fGitLab() {
	cd /home/git
	sudo rm -rf *
	sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 7-7-stable gitlab
#### Config
	# Go to GitLab installation folder
	cd /home/git/gitlab

# Copy the example GitLab config
	sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

# Update GitLab config file, follow the directions at top of file
	sudo -u git -H editor config/gitlab.yml

# Make sure GitLab can write to the log/ and tmp/ directories
	sudo chown -R git log/
	sudo chown -R git tmp/
	sudo chmod -R u+rwX,go-w log/
	sudo chmod -R u+rwX tmp/

# Create directory for satellites
	sudo -u git -H mkdir /home/git/gitlab-satellites
	sudo chmod u+rwx,g=rx,o-rwx /home/git/gitlab-satellites

# Make sure GitLab can write to the tmp/pids/ and tmp/sockets/ directories
	sudo chmod -R u+rwX tmp/pids/
	sudo chmod -R u+rwX tmp/sockets/

# Make sure GitLab can write to the public/uploads/ directory
	sudo chmod -R u+rwX  public/uploads

# Copy the example Unicorn config
	sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb

# Find number of cores
	nproc

# Enable cluster mode if you expect to have a high load instance
# Ex. change amount of workers to 3 for 2GB RAM server
# Set the number of workers to at least the number of cores
	sudo -u git -H editor config/unicorn.rb

# Copy the example Rack attack config
	sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

# Configure Git global settings for git user, useful when editing via web
# Edit user.email according to what is set in gitlab.yml
	sudo -u git -H git config --global user.name "GitLab"
	sudo -u git -H git config --global user.email "example@example.com"
	sudo -u git -H git config --global core.autocrlf input

# Configure Redis connection settings
	sudo -u git -H cp config/resque.yml.example config/resque.yml

# Change the Redis socket path if you are not using the default Debian / Ubuntu configuration
	sudo -u git -H editor config/resque.yml

#### Config DB
# PostgreSQL only:
	sudo -u git cp config/database.yml.postgresql config/database.yml

# MySQL and remote PostgreSQL only:
# Update username/password in config/database.yml.
# You only need to adapt the production settings (first part).
# If you followed the database guide then please do as follows:
# Change 'secure password' with the value you have given to $password
# You can keep the double quotes around the password
	sudo -u git -H editor config/database.yml

# PostgreSQL and MySQL:
# Make config/database.yml readable to git only
	sudo -u git -H chmod o-rwx config/database.yml

#	sudo -u git mv Gemfile Gemfile.orig
#	sudo -u git mv Gemfile.lock Gemfile.lock.orig
#	sudo -u git tar xzvf $DIR_CUR/Gemfiles_20130802.tar.gz
#	sudo -u git ex Gemfile <<EOF
#:%s/https:\/\/rubygems.org/http:\/\/rubygems.org/g
#:wq
#EOF
	sudo -u git wget https://gitlab.com/gitlab-org/gitlab-ce/raw/5-4-stable/config/puma.rb.example -O config/puma.rb

	cd ~
	wget http://rubygems.org/downloads/modernizr-2.6.2.gem
	sudo gem install modernizr

	rm -rf libv8
	git clone git://github.com/cowboyd/libv8.git
	cd libv8
	bundle install
	bundle exec rake checkout
	bundle exec rake compile
	sudo gem install therubyracer


	cd /home/git/gitlab
	sudo apt-get install -y nodejs

#### Install Gems
# For PostgreSQL (note, the option says "without ... mysql")
	sudo -u git -H bundle install --deployment --without development test mysql aws

# Or if you use MySQL (note, the option says "without ... postgres")
	sudo -u git -H bundle install --deployment --without development test postgres aws

#### Install GitLab Shell
# Run the installation task for gitlab-shell (replace `REDIS_URL` if needed):
	sudo -u git -H bundle exec rake gitlab:shell:install[v2.4.3] REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production

# By default, the gitlab-shell config is generated from your main GitLab config.
# You can review (and modify) the gitlab-shell config as follows:
	sudo -u git -H editor /home/git/gitlab-shell/config.yml

#### Initialize Database and Activate Advanced Features
	sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production

#sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=1234


#### Install Init Script
	sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
	sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab
	sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production
	sudo update-rc.d gitlab defaults 21
}

fNginx() {
	sudo apt-get install -y nginx
	cd /home/git/gitlab
	sudo cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
	sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab
	
}
#################################################################

if [ ! -e "$SWAPFILE" ] ; then
	FgNeedSwap=1
else
	let "_SIZE = $SWAP_BS * $SWAP_COUNT"
	SWSIZE=`fFSize $SWAPFILE`
	if [ "$_SIZE" -ne $SWSIZE ] ; then
		sudo swapoff $SWAPFILE
		FgNeedSwap=1
	fi
fi
if [ "$FgNeedSwap" -eq "1" ] ; then
	fMkSwapFile
fi


fAddFstab
fAddGitUser
fPackage
fRuby
fDatabase
fRedis
fGitLab
fNginx
