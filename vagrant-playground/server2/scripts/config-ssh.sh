#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/../../"

ssh-keygen -R server2
ssh-add -k .vagrant/machines/server2/virtualbox/private_key
ssh-keyscan -H server2 >> ~/.ssh/known_hosts
