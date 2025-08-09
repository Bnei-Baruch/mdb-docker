#!/usr/bin/env bash
set +e
set -x

# bring up services
docker compose pull
docker compose up -d

echo "wait for services to come up"
sleep 60

# prefix environment in configs on environment other than production
# .env -> KMEDIA_MDB_VERSION = <env>
# .env -> MDB_ADMIN_VERSION = <env>
# docker-compose.yml -> mdb_links.BASE_URL = https://<env>-cdn.kabbalahmedia.info/
# api/config.toml -> nats.client-id = "<env>-archive-backend-docker"
# set ./monitoring/alloy.config.hcl - loki credendtials

# DB migrations tools
wget https://github.com/ko1nksm/shdotenv/releases/latest/download/shdotenv -O /usr/local/bin/shdotenv
chmod +x /usr/local/bin/shdotenv
wget https://github.com/elwinar/rambler/releases/download/v5.4.0/rambler-linux-amd64 -O /usr/local/bin/rambler
chmod +x /usr/local/bin/rambler


# make sure everything is up and running correctly here


# install cron jobs
sed "s|<INSTALL_DIR>|$(pwd)|g" host/mdb.cron.txt > /etc/cron.d/mdb

# make sure crond.service is started and enabled
systemctl status crond
systemctl enable crond
systemctl start crond


# CI/CD reminder
echo "REMINDER: setup ssh access for CI/CD agents"
