#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# System packages
dnf5 install -y \
  fish \
  foot
  
#Install Niri
dnf5 -y copr enable yalter/niri 
dnf5 -y install niri
dnf5 -y copr disable yalter/niri

# systemctl enable niri

# WM and QShell
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf install -y noctalia-shell

mkdir -p /etc/niri/
cp /ctx/niri-config.kdl /etc/niri/config.kdl

#### Example for enabling a System Unit File

systemctl enable podman.socket
