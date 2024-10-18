#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

server1/scripts/config-ssh.sh > /dev/null 2>&1
ssh vagrant@server1.vagrant.test 'sudo bash -s' < _install_basic_server_configuration.sh
