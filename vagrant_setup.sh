#!/bin/bash

# fix for error message from Vagrant, but it may still show up
if `tty -s`; then
   mesg n
fi

# set source directory
APP_DIR=/home/vagrant/source
NODE_VERSION=${NODE_VERSION:-'0.10.28'}
PGDIR=/etc/postgresql/9.3/main # Use idx 1 of pg version arr.

sudo apt-get update -y
sudo apt-get upgrade

# install git
sudo apt-get install git -y -q
echo "Git has been installed!"

echo "Installing screen"
sudo apt-get -q -y install screen

echo "Installing vim"
sudo apt-get -q -y install vim

echo "Installing build-essential"
sudo apt-get -q -y install build-essential

echo "Installing postgres"
sudo apt-get -q -y install postgresql

echo "Installing nvm & latest node"
sudo apt-get -q -y install nodejs
sudo apt-get -q -y install npm

sudo ln -s /usr/bin/nodejs /usr/bin/node

echo "copying configs..."

# First we backup the original Postgres config. Next we'll have postgres
# listen on all IP's instead of just localhost. Install plv8
# custom_variable_class for the plv8 postgres module. Then finally overwrite
# the original config file and change ownwership to the postgres user.
sudo cp $PGDIR/postgresql.conf $PGDIR/postgresql.conf.default # Backup the config file
sudo cat $PGDIR/postgresql.conf.default | sed "s/#listen_addresses = \S*/listen_addresses = \'*\'/" | sudo tee $PGDIR/postgresql.conf > /dev/null
sudo chown postgres $PGDIR/postgresql.conf

# First we backup the original pg_hba config file. Next we will enable
# logging into postgres from outside the host machine.
sudo cp $PGDIR/pg_hba.conf $PGDIR/pg_hba.conf.default
sudo cat $PGDIR/pg_hba.conf.default | sed "s/local\s*all\s*postgres.*/local\tall\tpostgres\ttrust/" | sed "s/local\s*all\s*all.*/local\tall\tall\ttrust/" | sed "s#host\s*all\s*all\s*127\.0\.0\.1.*#host\tall\tall\t127.0.0.1/32\ttrust#" | sudo tee $PGDIR/pg_hba.conf > /dev/null
sudo chown postgres $PGDIR/pg_hba.conf

log "restarting postgres..."
sudo service postgresql restart

# go to source directory
#cdir $APP_DIR
#git reset --hard

cd $APP_DIR/server && npm install

echo "The install development script is done!"
