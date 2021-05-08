#!/bin/sh

set -e

if [ -z "$PGUSER" ]; then
	export PGUSER="$(id -un)"
fi
if [ -z "$PGDATABASE" ]; then
	export PGDATABASE="$(id -un)"
fi
sudo apt-get update
#sudo apt-get install -y wget unzip openjdk-8-jdk
sudo apt-get install -y git postgresql-12 postgresql-client-common pgtap
if ! psql -c '\l' -d template1 >/dev/null 2>&1; then
	echo "===> Creating user $PGUSER for PostgreSQL"
	sudo -u postgres createuser -s -d -r -l -e "$PGUSER"
fi
if ! psql -c '\l' -d "$PGDATABASE" >/dev/null 2>&1; then
	echo "===> Creating database $PGDATABASE for PostgreSQL"
	createdb -e "$PGDATABASE"
fi
echo "===> Enabling pgTAP extension in database"
psql -c 'CREATE EXTENSION IF NOT EXISTS pgtap'

echo "Successfully set up PostgreSQL"
