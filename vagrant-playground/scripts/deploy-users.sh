#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

ssh vagrant@server1.vagrant.test 'sudo bash -s' < _deploy_users.sh
ssh vagrant@server2.vagrant.test 'sudo bash -s' < _deploy_users.sh

