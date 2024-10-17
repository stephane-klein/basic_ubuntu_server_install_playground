# Vagrant playground

The goal of the playground in this folder is to work safely on setting up deployment scripts
on a virtual server installed locally on your workspace station.

The virtual server is managed by [Vagrant](https://github.com/hashicorp/vagrant/) and proposed by [VirtualBox](https://en.wikipedia.org/wiki/VirtualBox).

# Prerequisites

- Install VirtualBox
- Install Vagrant
- Install [vagrant-dns](https://github.com/BerlinVagrant/vagrant-dns) plugin:

```sh
$ vagrant plugin install vagrant-dns  --plugin-version 2.4.
```

If your Workstation OS is Fedora, then you can follow these installation instructions: https://github.com/stephane-klein/vagrant-virtualbox-fedora?tab=readme-ov-file#prepare-your-computer


# Getting started

Launching the virtual server:

```sh
$ vagrant box update # (optional)
$ vagrant up
$ vagrant dns --install
$ vagrant dns --start
```

Check hostname resolution:

```
$ resolvectl query server2.vagrant.test
server2.vagrant.test: 192.168.56.23

-- Information acquired via protocol DNS in 4.2ms.
-- Data is authenticated: no; Data was acquired via local or encrypted transport: no
-- Data from: network
```

```sh
$ ./scripts/install_basic_server_configuration.sh
```

## Teardown

```sh
$ vagrant destroy -f
```
