#!/usr/bin/env bash
set +e
set -x

dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf upgrade --refresh
dnf -y install \
  git \
  jq \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin \
  httpd-tools

systemctl --now enable docker
docker version

# Install node_exporter
mkdir /opt/node_exporter 
cd /opt/node_exporter/
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
tar -xzvf node_exporter-1.9.1.linux-amd64.tar.gz
mv node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
cat <<'EOF' | sudo tee /etc/systemd/system/node-exporter.service > /dev/null
[Unit]
Description=node_exporter Service
Wants=basic.target
After=basic.target network.target

[Service]
User=root
Group=root
PermissionsStartOnly=true
ExecStart=/usr/local/bin/node_exporter  --collector.mountstats --collector.textfile.directory /etc/prometheus/node_exporter/data
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=always
RestartSec=30s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl --now enable node-exporter
systemctl status node-exporter

echo "Add this host to prometheus targets"

# Download installation sources
git clone https://github.com/Bnei-Baruch/mdb-docker.git

touch mdb-docker/.env
echo "fill in .env file and continue to post-install.sh"
