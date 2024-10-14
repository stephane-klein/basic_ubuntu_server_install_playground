#!/usr/bin/env bash

set -ev

export DEBIAN_FRONTEND=noninteractive
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
apt-get update -y
apt-get install -yq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg

# Basic safety element configuration, inspired by article https://kenhv.com/blog/securing-a-linux-server

usermod root --shell /sbin/nologin
passwd --lock root

cat <<EOF > /etc/ssh/sshd_config.d/99-sklein-security.conf
Protocol 2
MaxAuthTries 3
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
KbdInteractiveAuthentication no
X11Forwarding no
EOF

systemctl restart ssh

# Install Docker
# This installation is based on https://docs.docker.com/engine/install/ubuntu/ documentation

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

install -m 0755 -d /etc/apt/keyrings
rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker info
