#!/usr/bin/env bash
set -e

PROJECT_FOLDER="/srv/monitoring_and_logging/"

mkdir -p ${PROJECT_FOLDER}

[ -f ${PROJECT_FOLDER}promtail-config.yaml ] && cp ${PROJECT_FOLDER}promtail-config.yaml ${PROJECT_FOLDER}promtail-config.yaml.bak
cat <<EOF > "${PROJECT_FOLDER}promtail-config.yaml"
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
      - source_labels: ['__journal_syslog_identifier']
        target_label: 'tag'

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
          host: $(hostname)
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
    network_mode: "host"
    volumes:
      - /var/lib/promtail/:/var/lib/promtail/
      - /var/log/journal:/var/log/journal
      - /run/log/journal:/run/log/journal
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/machine-id:/etc/machine-id
      - ./promtail-config.yaml:/etc/promtail/promtail-config.yaml
    command:
      - "-config.file=/etc/promtail/promtail-config.yaml"

  node_exporter:
    image: quay.io/prometheus/node-exporter:v1.8.2
    container_name: node_exporter
    network_mode: "host"
    command:
      - '--path.rootfs=/host'
    pid: host
    restart: unless-stopped
    volumes:
      - '/:/host:ro,rslave'

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.49.1
    container_name: cadvisor
    network_mode: "host"
    restart: unless-stopped
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - "/dev/kmsg:/dev/kmsg"
EOF

ufw allow 9080 # promtail
ufw allow 9100 # node exporter
ufw allow 8080 # cadvisor

cd ${PROJECT_FOLDER}
docker compose pull

if [ "$promtail_config_modified" == "true" ]; then
    docker compose stop promtail
fi

docker compose up -d --remove-orphans
