# Basic Ubuntu Server installation Playground

The aim of this repository is to serve as a reference for deploying Ubuntu cloud LTS servers.

This deployment “skeleton” will have to meet the following specifications:

- Installation via Terraform on Scaleway (not implemented yet)
- Creating unix users and their ssh keys 
- Basic security:
  - Configure OpenSSH [hardening](https://kenhv.com/blog/securing-a-linux-server)
  - Setup [fail2ban](https://en.wikipedia.org/wiki/Fail2ban)
  - Setup [IPsum](https://github.com/stamparm/ipsum) - Daily feed of bad IPs (with blacklist hit scores)
  - Configure [UFW](https://en.wikipedia.org/wiki/Uncomplicated_Firewall) (Uncomplicated Firewall)
  - Setup [Linux Audit](https://github.com/linux-audit/audit-userspace) (not implemented yet)
  - Setup a script to send Loki a daily list of security packages to be installed on the server
  - Setup log centralization with:
    - [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/)
    - [Loki](https://en.wikipedia.org/wiki/Grafana)
    - [Grafana](https://en.wikipedia.org/wiki/Grafana)
  - Setup hardware and OS metrics with:
    - [Node exporter](https://github.com/prometheus/node_exporter)
    - [cAdvisor](https://github.com/google/cadvisor) (for Docker containers)
    - [Prometheus](https://github.com/prometheus/prometheus)
    - [Grafana](https://en.wikipedia.org/wiki/Grafana)
      - [Node Exporter Grafana Dashboards](https://github.com/rfmoz/grafana-dashboards)
      - [cAdvisor exporter - Docker containers Overview](https://grafana.com/grafana/dashboards/21743-cadvisor-exporter-docker-containers-overview/)
  - Setup [ntfy](https://ntfy.sh/) and [Grafana Ntify Webhook integration](https://github.com/academo/grafana-alerting-ntfy-webhook-integration) to send Grafana alert notifications to smartphones
- Docker installation

More information, see [Projet 14 - Script de base d'installation d'un serveur Ubuntu LTS](https://notes.sklein.xyz/Projet%2014/) (in french).

## Getting started

You can start testing deployment scripts safely locally via Vagrant and VirtualBox: [`vagrant-playground/`](./vagrant-playground/).

## Resources

- [Securing A Linux Server](https://kenhv.com/blog/securing-a-linux-server)
