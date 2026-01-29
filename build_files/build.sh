#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y gh cloud-init nodejs npm

# Install opencode-ai globally
HOME=/var/tmp npm i -g opencode-ai@latest

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Create cverna user using systemd-sysusers
cp /ctx/cverna.conf /usr/lib/sysusers.d/cverna.conf
systemd-sysusers /usr/lib/sysusers.d/cverna.conf
mkdir -p /var/home/cverna
chown cverna:cverna /var/home/cverna

#### Install systemd mount unit for virtiofs workspace
mkdir -p /var/workspace
cp /ctx/var-workspace.mount /etc/systemd/system/var-workspace.mount
systemctl enable var-workspace.mount

#### Install systemd mount unit for virtiofs host config
cp /ctx/var-home-cverna-.config.mount /etc/systemd/system/var-home-cverna-.config.mount
systemctl enable var-home-cverna-.config.mount

#### Install opencode serve systemd service
cp /ctx/opencode-serve.service /etc/systemd/system/opencode-serve.service
systemctl enable opencode-serve.service

#### Create opencode environment directory
mkdir -p /etc/opencode
touch /etc/opencode/opencode.env
chmod 660 /etc/opencode/opencode.env
chown cverna:cverna /etc/opencode/opencode.env

#### Install OpenShift client (oc)
tar -xzf /ctx/openshift-client-linux-arm64.tar.gz -C /usr/local/bin oc kubectl

### Install Jira cli client
tar -xzf /ctx/jira_1.7.0_linux_arm64.tar.gz -C /usr/local/bin --strip-components=2 jira_1.7.0_linux_arm64/bin/jira



