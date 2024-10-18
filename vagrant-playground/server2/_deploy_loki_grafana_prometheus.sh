#!/usr/bin/env bash
set -e

PROJECT_FOLDER="/srv/loki_prometheus_grafana/"

mkdir -p ${PROJECT_FOLDER}


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

cat <<'EOF' > "${PROJECT_FOLDER}docker-compose.yaml"
services:
  loki:
    image: grafana/loki:3.2.0
    restart: unless-stopped
    user: root
    ports:
      - "3100:3100"
    command: "-config.file=/etc/loki/local-config.yaml"
    volumes:
      - ./loki-config.yaml:/etc/loki/local-config.yaml
      - /var/lib/loki/:/var/lib/loki/

  grafana:
    image: grafana/grafana:11.2.2
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=password
      - GF_USERS_DEFAULT_THEME=light
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3000:3000"
EOF

cd ${PROJECT_FOLDER}
docker compose pull
docker compose down
docker compose up -d

# Generate Grafana API Token
until curl -s http://localhost:3000/api/health | grep "ok"; do
    echo "Waiting for Grafana to be ready...";
    sleep 5;
done;

if [ -f "./grafana_token.json" ]; then
    echo "Grafana already exists"
else
    echo "Grafana is ready, generating API token...";
    curl -s -X POST http://localhost:3000/api/auth/keys \
        -H "Content-Type: application/json" \
        -u admin:password \
        -d '{"name":"auto-generated-token","role":"Admin"}' > ./grafana_token.json;
    echo "Token generated:";
    cat ./grafana_token.json;
fi

# Add Loki datasource to Grafana
if [ -f "./loki_source_message.json" ]; then
    echo "Loki source already exists"
else
    echo "Add Loki datasource to Grafana"
    curl -s -X POST "http://localhost:3000/api/datasources" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $(cat grafana_token.json  | jq -r .key)" \
      -d '{
        "name": "Loki",
        "type": "loki",
        "url": "http://loki:3100",
        "access": "proxy",
        "basicAuth": false,
        "jsonData": {
          "maxLines": 1000
        }
      }' > ./loki_source_message.json
    echo "Loki datasource to Grafana added"
fi
