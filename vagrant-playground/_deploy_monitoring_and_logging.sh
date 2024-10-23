#!/usr/bin/env bash
set -e

PROJECT_FOLDER="/srv/monitoring_and_logging/"

mkdir -p ${PROJECT_FOLDER}

cp ${PROJECT_FOLDER}promtail-config.yaml ${PROJECT_FOLDER}promtail-config.yaml.bak
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
      - source_labels: ['__journal__hostname']
        target_label: host
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'
      - source_labels: ['__journal_priority']
        target_label: 'priority'

  # Documentation: https://grafana.com/docs/loki/latest/send-data/promtail/configuration/#docker_sd_configs
  - job_name: "docker"
    docker_sd_configs:
      - host: "unix:///var/run/docker.sock"
        refresh_interval: "1s"
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: "container_name"
      - source_labels: ['__meta_docker_container_id']
        target_label: "container_id"
    pipeline_stages:
      - docker: {}
      - static_labels:
          host: server1
          job: docker
EOF
promtail_config_modified=$(if [ "$(md5sum ${PROJECT_FOLDER}/promtail-config.yaml | awk '{ print $1 }')" != "$(md5sum ${PROJECT_FOLDER}/promtail-config.yaml.bak | awk '{ print $1 }')" ]; then echo true; else echo false; fi)

cat <<'EOF' > "${PROJECT_FOLDER}docker-compose.yaml"
services:
  promtail:
    container_name: promtail
    image: grafana/promtail:3.2.0
    user: "0:0"
    restart: unless-stopped
    ports:
      - 9080:9080
    volumes:
      - /var/lib/promtail/:/var/lib/promtail/
      - /var/log/journal:/var/log/journal
      - /run/log/journal:/run/log/journal
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/machine-id:/etc/machine-id
      - ./promtail-config.yaml:/etc/promtail/promtail-config.yaml
    command:
      - "-config.file=/etc/promtail/promtail-config.yaml"
EOF

cd ${PROJECT_FOLDER}
docker compose pull

if [ "$promtail_config_modified" == "true" ]; then
    docker compose stop promtail
fi

docker compose up -d
