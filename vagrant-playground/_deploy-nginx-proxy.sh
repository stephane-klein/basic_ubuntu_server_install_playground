#!/usr/bin/env bash
set -e

PROJECT_FOLDER="/srv/nginx-proxy/"

mkdir -p ${PROJECT_FOLDER}

cat <<'EOF' > "${PROJECT_FOLDER}docker-compose.yaml"
services:
  nginx-proxy:
    image: nginxproxy/nginx-proxy:1.6.3
    container_name: nginx-proxy
    restart: unless-stopped
    network_mode: "host"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs:rw
      - ./vhost.d:/etc/nginx/vhost.d
      - ./html:/usr/share/nginx/html
EOF

ufw allow 80
ufw allow 443

cd ${PROJECT_FOLDER}

mkdir -p ./certs/
openssl req -x509 \
    -newkey rsa:4096 \
    -sha256 \
    -nodes \
    -days 365 \
    -subj "/CN=vagrant.test"  \
    -keyout "./certs/vagrant.test.key" \
    -out "./certs/vagrant.test.crt"

docker compose pull
docker compose up -d --remove-orphans
