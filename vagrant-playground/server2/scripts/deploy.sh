#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

scripts/config-ssh.sh > /dev/null 2>&1
ssh vagrant@server2.vagrant.test 'sudo bash -s' < _deploy_loki_grafana_prometheus.sh

# Wait Grafana is ready
until curl -s http://grafana.vagrant.test:3000/api/health | grep "ok"; do
    echo "Waiting for Grafana to be ready...";
    sleep 5;
done;

../server2/scripts/apply-grafana-resources.sh
