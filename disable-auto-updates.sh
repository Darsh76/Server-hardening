#!/bin/bash

set -e

echo "Stopping apt timers..."
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer

echo "Disabling apt timers..."
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer

echo "Masking apt timers..."
sudo systemctl mask apt-daily.timer
sudo systemctl mask apt-daily-upgrade.timer

echo "Stopping apt services..."
sudo systemctl stop apt-daily.service
sudo systemctl stop apt-daily-upgrade.service

echo "Masking apt services..."
sudo systemctl mask apt-daily.service
sudo systemctl mask apt-daily-upgrade.service

echo "Disabling unattended-upgrades service..."
sudo systemctl stop unattended-upgrades
sudo systemctl disable unattended-upgrades
sudo systemctl mask unattended-upgrades

echo "Disabling unattended-upgrades in config..."
sudo bash -c 'cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF'

echo "Disabling periodic apt tasks..."
sudo bash -c 'cat > /etc/apt/apt.conf.d/10periodic <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF'

echo "Cleaning up any remaining apt timers..."
systemctl list-timers | grep apt || true

echo "Done: automatic updates and upgrades are disabled."