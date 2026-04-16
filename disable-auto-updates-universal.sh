#!/bin/bash

set -e

echo "Detecting OS..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect OS. Exiting."
    exit 1
fi

echo "Detected: $ID"

# ---------------------------
# UBUNTU / DEBIAN
# ---------------------------
if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then

    echo "Disabling Ubuntu/Debian auto updates..."

    # apt timers
    systemctl stop apt-daily.timer apt-daily-upgrade.timer || true
    systemctl disable apt-daily.timer apt-daily-upgrade.timer || true
    systemctl mask apt-daily.timer apt-daily-upgrade.timer || true

    systemctl stop apt-daily.service apt-daily-upgrade.service || true
    systemctl mask apt-daily.service apt-daily-upgrade.service || true

    # unattended upgrades
    systemctl stop unattended-upgrades || true
    systemctl disable unattended-upgrades || true
    systemctl mask unattended-upgrades || true

    # configs
    cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

    cat > /etc/apt/apt.conf.d/10periodic <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

    echo "Ubuntu/Debian auto updates disabled."

# ---------------------------
# RHEL / CENTOS / ALMA / ROCKY
# ---------------------------
elif [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "almalinux" || "$ID" == "rocky" || "$ID_LIKE" == *"rhel"* ]]; then

    echo "Disabling RHEL-based auto updates..."

    # dnf-automatic
    systemctl stop dnf-automatic.timer dnf-automatic.service || true
    systemctl disable dnf-automatic.timer dnf-automatic.service || true
    systemctl mask dnf-automatic.timer dnf-automatic.service || true

    # yum-cron (legacy)
    systemctl stop yum-cron || true
    systemctl disable yum-cron || true
    systemctl mask yum-cron || true

    # configs
    if [ -f /etc/dnf/automatic.conf ]; then
        sed -i 's/^apply_updates = yes/apply_updates = no/' /etc/dnf/automatic.conf || true
        sed -i 's/^upgrade_type =.*/upgrade_type = default/' /etc/dnf/automatic.conf || true
    fi

    if [ -f /etc/yum/yum-cron.conf ]; then
        sed -i 's/^apply_updates = yes/apply_updates = no/' /etc/yum/yum-cron.conf || true
    fi

    echo "RHEL-based auto updates disabled."

# ---------------------------
# UNKNOWN OS
# ---------------------------
else
    echo "Unsupported OS: $ID"
    exit 1
fi

echo "Done: automatic updates have been disabled."