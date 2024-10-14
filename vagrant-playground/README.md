# Vagrant playground

The goal of the playground in this folder is to work safely on setting up deployment scripts
on a virtual server installed locally on your workspace station.

The virtual server is managed by [Vagrant](https://github.com/hashicorp/vagrant/) and proposed by [VirtualBox](https://en.wikipedia.org/wiki/VirtualBox).

# Prerequisites

- Install VirtualBox
- Install Vagrant
- Install [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin:

```
$ vagrant plugin install vagrant-hostmanager  --plugin-version 1.8.10
```

If your Workstation OS is Fedora, then you can follow these installation instructions: https://github.com/stephane-klein/vagrant-virtualbox-fedora?tab=readme-ov-file#prepare-your-computer


# Getting started

Launching the virtual server:

```
$ vagrant box update # (optional)
$ vagrant up
```

```
$ ./scripts/install_basic_server_configuration.sh
```

## Teardown

```
$ vagrant destroy -f
```
