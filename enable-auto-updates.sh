#!/bin/bash

set -e

echo "Unmasking apt timers..."
sudo systemctl unmask apt-daily.timer
sudo systemctl unmask apt-daily-upgrade.timer

echo "Enabling apt timers..."
sudo systemctl enable apt-daily.timer
sudo systemctl enable apt-daily-upgrade.timer

echo "Starting apt timers..."
sudo systemctl start apt-daily.timer
sudo systemctl start apt-daily-upgrade.timer

echo "Unmasking apt services..."
sudo systemctl unmask apt-daily.service
sudo systemctl unmask apt-daily-upgrade.service

echo "Enabling and starting apt services..."
sudo systemctl enable apt-daily.service
sudo systemctl start apt-daily.service
sudo systemctl enable apt-daily-upgrade.service
sudo systemctl start apt-daily-upgrade.service

echo "Enabling unattended-upgrades service..."
sudo systemctl unmask unattended-upgrades
sudo systemctl enable unattended-upgrades
sudo systemctl start unattended-upgrades

echo "Restoring apt periodic configuration..."
sudo bash -c 'cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF'

sudo bash -c 'cat > /etc/apt/apt.conf.d/10periodic <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF'

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Done: automatic updates and upgrades are restored."