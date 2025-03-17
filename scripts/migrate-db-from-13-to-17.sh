#!/bin/bash

set -xe

elc stop database

sudo cp -r $PWD/services/database/data $PWD/services/database/data-13-backup

docker rm -f pg_13_for_migrate

docker run -d --name pg_13_for_migrate \
  -v $PWD/services/database/data:/var/lib/postgresql/data \
  dockerhub.greensight.ru/services/postgis:13-3.1

sleep 5

while ! docker exec -it pg_13_for_migrate pg_isready; do
  sleep 1
done

echo Done

docker exec -it pg_13_for_migrate pg_dumpall -U postgres --clean > backup.sql

docker rm -f pg_13_for_migrate

sudo rm -rf $PWD/services/database/data
sudo mkdir $PWD/services/database/data
sudo chmod 777 $PWD/services/database/data

elc start database
sleep 5

cat backup.sql | elc exec --no-tty -c database psql -U postgres

echo "ALTER USER postgres WITH PASSWORD 'example';" | elc exec --no-tty -c database psql -U postgres
