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

- Install [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin:

```sh
$ vagrant plugin install vagrant-hostmanager  --plugin-version 1.8.10
```

- Install Mise
- Use Mise to install [Grafana Grizzly](https://github.com/daveneeley/asdf-grafana-grizzly):

```sh
$ mise plugin add grafana-grizzly https://github.com/daveneeley/asdf-grafana-grizzly.git
$ mise install grafana-grizzly 0.5.0
```

If your Workstation OS is Fedora, then you can follow these installation instructions: https://github.com/stephane-klein/vagrant-virtualbox-fedora?tab=readme-ov-file#prepare-your-computer


# Getting started

Launching the virtual server:

```sh
$ vagrant box update # (optional)
$ vagrant up
$ vagrant dns --start
``` 

Check DNS configuration:

```sh
$ vagrant dns -l
/server1.vagrant.test/ => 192.168.56.22
/server2.vagrant.test/ => 192.168.56.23
/grafana.vagrant.test/ => 192.168.56.23
/loki.vagrant.test/ => 192.168.56.23
```

Check hostname resolution:

```sh
$ resolvectl query server2.vagrant.test
server2.vagrant.test: 192.168.56.23

-- Information acquired via protocol DNS in 4.2ms.
-- Data is authenticated: no; Data was acquired via local or encrypted transport: no
-- Data from: network
```

First, we need to deploy server2, which monitors and aggregates logs (Loki, Grafana, Prometheus).

```sh
$ ./server2/scripts/install_basic_server_configuration.sh
$ ./server2/scripts/deploy.sh
```


```sh
$ ./server1/scripts/install_basic_server_configuration.sh
$ ./server1/scritps/deploy.sh
```

Go to http://grafana.vagrant.test:3000 (login: `admin`, password: `password`)

## Teardown

```sh
$ vagrant destroy -f
```

 ## Why We Did It This Way?

Why does this project use both [vagrant-dns](https://github.com/BerlinVagrant/vagrant-dns) and [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager)?

*vagrant-dns* configures `*.test` hostnames via a [systemd-resolved](https://man.archlinux.org/man/systemd-resolved.service.8.en) configuration file named `/etc/systemd/resolved.conf.d/vagrant-dns.conf`.

Problem: the stically linked binary version of [Grafana Grizzly](https://github.com/daveneeley/asdf-grafana-grizzly) does
not use the [getaddrinfo](https://man.archlinux.org/man/getaddrinfo.3.en) function to resolve hostnames, but fetches
the information directly from the `nameserver` parameter in `/etc/resolv.conf` and the contents of `/etc/hosts`.

As a result, the configuration set up by *vagrant-dns* isn't used and `server2.vagrant.test` is not resolved on the host server.

Solution found to enable *Grafana Grizzy* to resolve `server2.vagrant.test`: use *vagrant-hostmanager* to configure virtual machine hostnames in `/etc/hosts`.

Why not just use *vagrant-hostmanager*?

*vagrant-hostmanager* sets hostname ip's in `/etc/hosts` for host server and virtual machines.

This configuration is not handled by Docker containers without tinkering.

On the other hand, by using a dns server with *vagrant-dns*, Docker containers can resolve virtual machine hostnames without tinkering.
