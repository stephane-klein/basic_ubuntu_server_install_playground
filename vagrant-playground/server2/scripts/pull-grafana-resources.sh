#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

source .envrc

rm -rf grafana_resources
grr pull grafana_resources -t Datasource,Dashboard,DashboardFolder,AlertRuleGroup,AlertNotificationPolicy,AlertContactPoint,AlertNotificationPolicy
