#!/usr/bin/env bash
set -e
#set -x

tmp_dir=$(mktemp -d -t migrations-"$(date +%Y-%m-%d-%H-%M-%S)"-XXXXXXXXXX)
echo "$tmp_dir"

eval "$(shdotenv -d docker)"
dummy="dummy_mdb"
docker create --name ${dummy} bneibaruch/mdb:${API_VERSION}
docker cp ${dummy}:/app/migrations "$tmp_dir"
ls -laR $tmp_dir

export RAMBLER_DATABASE=mdb
export RAMBLER_DIRECTORY="$tmp_dir/migrations"
export RAMBLER_DRIVER=postgresql
export RAMBLER_HOST=$MDB_HOST
export RAMBLER_PORT=$MDB_PORT
export RAMBLER_TABLE=migrations
export RAMBLER_USER=$MDB_USER
export RAMBLER_PASSWORD=$MDB_PASSWORD
rambler apply -a
