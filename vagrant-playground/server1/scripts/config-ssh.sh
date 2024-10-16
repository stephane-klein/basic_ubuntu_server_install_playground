#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/../../"

ssh-keygen -R server1.example.com
ssh-add -k .vagrant/machines/server1/virtualbox/private_key
ssh-keyscan -H server1.example.com >> ~/.ssh/known_hosts
