#!/usr/bin/env bash
set -e

PROJECT_FOLDER="/srv/monitoring_and_logging/"

mkdir -p ${PROJECT_FOLDER}

cat <<'EOF' > "${PROJECT_FOLDER}promtail-config.yaml"
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: http://grafana.vagrant.test:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    journal:
      path: /var/log/journal
      labels:
        job: "systemd-journal"
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'
      - source_labels: ['__journal_priority']
        target_label: 'priority'

  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: "docker"
          __path__: /var/lib/docker/containers/*/*.log
EOF

cat <<'EOF' > "${PROJECT_FOLDER}docker-compose.yaml"
services:
  promtail:
    image: grafana/promtail:3.2.0
    user: "0:0"
    restart: unless-stopped
    ports:
      - 9080:9080
    volumes:
      - /var/lib/promtail/:/var/lib/promtail/
      - /var/log/journal:/var/log/journal
      - /run/log/journal:/run/log/journal
      - /var/lib/docker/containers:/var/lib/docker/containers
      - /var/log:/var/log
      - /etc/machine-id:/etc/machine-id
      - ./promtail-config.yaml:/etc/promtail/promtail-config.yaml
    command:
      - "-config.file=/etc/promtail/promtail-config.yaml"
EOF

cd ${PROJECT_FOLDER}
docker compose pull
docker compose up -d
