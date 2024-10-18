#!/usr/bin/env bash
set -evuo pipefail

cd "$(dirname "$0")/../../"

./server1/scripts/config-ssh.sh #> /dev/null 2>&1

ssh vagrant@server2 'sudo bash -s' < _install_basic_server_configuration.sh
