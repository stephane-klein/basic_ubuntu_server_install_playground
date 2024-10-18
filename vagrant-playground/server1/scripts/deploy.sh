#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

scripts/config-ssh.sh > /dev/null 2>&1
ssh vagrant@server1.vagrant.test 'sudo bash -s' < ../_deploy_monitoring_and_logging.sh
