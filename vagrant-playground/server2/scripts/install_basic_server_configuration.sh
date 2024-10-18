#!/usr/bin/env bash
set -evuo pipefail

cd "$(dirname "$0")/../../"

./server2/scripts/config-ssh.sh > /dev/null 2>&1

ssh vagrant@server2.vagrant.test 'sudo bash -s' < _install_basic_server_configuration.sh
