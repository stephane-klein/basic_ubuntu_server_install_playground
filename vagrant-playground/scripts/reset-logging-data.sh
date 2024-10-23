#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/../"

server1/scripts/config-ssh.sh > /dev/null 2>&1
server2/scripts/config-ssh.sh > /dev/null 2>&1

ssh vagrant@server1.vagrant.test 'sudo bash -s' <<'EOF'
cd /srv/monitoring_and_logging/
sudo docker compose stop promtail
sudo rm -f /var/lib/promtail/positions.yaml
EOF

ssh vagrant@server2.vagrant.test 'sudo bash -s' <<'EOF'
cd /srv/loki_prometheus_grafana/
sudo docker compose stop loki
sudo rm -rf /var/lib/loki
sudo docker compose up -d loki
EOF

ssh vagrant@server1.vagrant.test 'sudo bash -s' <<'EOF'
cd /srv/monitoring_and_logging/
sudo docker compose up -d promtail
EOF
