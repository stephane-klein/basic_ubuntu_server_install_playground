# Basic Ubuntu Server installation Playground

The aim of this repository is to serve as a reference for deploying Ubuntu cloud LTS servers.

This deployment “skeleton” will have to meet the following specifications:

- Installation via Terraform on Scaleway
- Basic security:
  - Configure OpenSSH
  - Configure UFW
  - Setup [IPsum](https://github.com/stamparm/ipsum) - Daily feed of bad IPs (with blacklist hit scores)
  - Setup fail2ban
  - Setup Linux Audit
  - Setup aptcron
- Docker installation

More information, see [Projet 14 - Script de base d'installation d'un serveur Ubuntu LTS](https://notes.sklein.xyz/Projet%2014/) (in french).

## Getting started

You can start testing deployment scripts safely locally via Vagrant and VirtualBox: [`vagrant-playground/`](./vagrant-playground/).

## Resources

- [Securing A Linux Server](https://kenhv.com/blog/securing-a-linux-server)
