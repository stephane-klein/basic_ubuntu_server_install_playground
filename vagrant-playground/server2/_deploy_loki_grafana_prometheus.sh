#!/usr/bin/env bash
set -e

PROJECT_FOLDER="/srv/loki_prometheus_grafana/"

mkdir -p ${PROJECT_FOLDER}

# Deploy loki-config.yaml
[ -f ${PROJECT_FOLDER}/loki-config.yaml ] && cp ${PROJECT_FOLDER}/loki-config.yaml ${PROJECT_FOLDER}/loki-config.yaml.bak
cat <<'EOF' > "${PROJECT_FOLDER}/loki-config.yaml"
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9095
  log_level: error

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2023-07-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  tsdb_shipper:
    active_index_directory: /var/lib/loki/tsdb-index
    cache_location: /var/lib/loki/tsdb-cache

  filesystem:
    directory: /var/lib/loki/chunks/

compactor:
  working_directory: /var/lib/loki/data/retention

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h

table_manager:
  retention_deletes_enabled: true
  retention_period: 168h

ruler:
  storage:
    type: local
    local:
      directory: /loki/rules
  rule_path: /loki/rules
  enable_api: true
EOF

loki_config_modified=$(if [ "$(md5sum ${PROJECT_FOLDER}/loki-config.yaml | awk '{ print $1 }')" != "$(md5sum ${PROJECT_FOLDER}/loki-config.yaml.bak | awk '{ print $1 }')" ]; then echo true; else echo false; fi)

# Deploy prometheus-config.yaml
[ -f ${PROJECT_FOLDER}/prometheus-config.yaml ] && cp ${PROJECT_FOLDER}/prometheus-config.yaml ${PROJECT_FOLDER}/prometheus-config.yaml.bak
cat <<'EOF' > "${PROJECT_FOLDER}/prometheus-config.yaml"
global:
  scrape_interval: 30s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: 
        - 'localhost:9090'

  - job_name: 'node_exporter'
    static_configs:
      - targets:
        - 'server1.vagrant.test:9100'
        - 'server2.vagrant.test:9100'

  - job_name: 'cadvisor'
    static_configs:
      - targets: 
        - 'server1.vagrant.test:8080'
        - 'server2.vagrant.test:8080'
EOF

prometheus_config_modified=$(if [ "$(md5sum ${PROJECT_FOLDER}/prometheus-config.yaml | awk '{ print $1 }')" != "$(md5sum ${PROJECT_FOLDER}/prometheus-config.yaml.bak | awk '{ print $1 }')" ]; then echo true; else echo false; fi)


cat <<'EOF' > "${PROJECT_FOLDER}docker-compose.yaml"
services:
  loki:
    container_name: loki
    image: grafana/loki:3.2.0
    restart: unless-stopped
    user: root
    network_mode: "host"
    command: "-config.file=/etc/loki/local-config.yaml"
    environment:
      - VIRTUAL_HOST=loki.vagrant.test
    volumes:
      - ./loki-config.yaml:/etc/loki/local-config.yaml
      - /var/lib/loki/:/var/lib/loki/

  grafana:
    container_name: grafana
    image: grafana/grafana:11.2.2
    restart: unless-stopped
    user: root
    environment:
      - VIRTUAL_HOST=grafana.vagrant.test
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=password
      - GF_USERS_DEFAULT_THEME=light
      - GF_USERS_ALLOW_SIGN_UP=false
    network_mode: "host"
    volumes:
      - /var/lib/grafana:/var/lib/grafana

  prometheus:
    container_name: prometheus
    image: quay.io/prometheus/prometheus:v2.55.0
    restart: unless-stopped
    user: root
    volumes:
      - ./prometheus-config.yaml:/etc/prometheus/prometheus.yaml
      - /var/lib/prometheus/:/prometheus
    network_mode: "host"
    command:
      - "--config.file=/etc/prometheus/prometheus.yaml"
      - "--storage.tsdb.path=/prometheus"
    environment:
      - VIRTUAL_HOST=prometheus.vagrant.test

  ntfy:
    image: binwiederhier/ntfy:v2.11.0
    restart: unless-stopped
    container_name: ntfy
    command:
      - serve
    environment: # Documentation https://github.com/binwiederhier/ntfy/blob/630f2957deb670dcacfe0a338091d7561f176b9c/docs/config.md?plain=1#L1373
      NTFY_LISTEN_HTTP: ":9000"
      VIRTUAL_HOST: ntfy.vagrant.test
      VIRTUAL_PORT: 9000
    user: root
    volumes:
      - /var/cache/ntfy:/var/cache/ntfy
    network_mode: "host"
    healthcheck:
        test: ["CMD-SHELL", "wget -q --tries=1 http://localhost:80/v1/health -O - | grep -Eo '\"healthy\"\\s*:\\s*true' || exit 1"]
        interval: 60s
        timeout: 10s
        retries: 3
        start_period: 40s

  grafana-ntfy:
    image: academo/grafana-ntfy:latest
    restart: unless-stopped
    container_name: grafana-ntfy
    network_mode: "host"
    command: "-port=9010 -ntfy-url=http://server2.vagrant.test:9000/grafana"
EOF

cd ${PROJECT_FOLDER}
docker compose pull

if [ "$loki_config_modified" == "true" ]; then
    docker compose stop loki
fi

if [ "$prometheus_config_modified" == "true" ]; then
    docker compose stop prometheus
fi

docker compose up -d --remove-orphans
