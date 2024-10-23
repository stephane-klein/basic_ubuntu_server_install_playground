#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

source .envrc

grr apply grafana_resources -t Datasource,Dashboard,DashboardFolder
