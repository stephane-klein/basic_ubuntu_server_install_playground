#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

ssh-keygen -R myserver.example.com

ssh-add -k .vagrant/machines/myserver/virtualbox/private_key

ssh-keyscan -H myserver.example.com >> ~/.ssh/known_hosts
