#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

scripts/config-ssh.sh > /dev/null 2>&1
ssh vagrant@server1.example.com 'sudo bash -s' < _install_basic_server_configuration.sh
